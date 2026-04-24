[CmdletBinding()]
param(
  # Optional Terraform root folder to run from.
  #
  # Usage examples:
  #   # Run from inside the terraform folder (default = current folder):
  #   .\run_deploy_with_tests.ps1
  #
  #   # Run from the parent folder and point at the terraform root (positional):
  #   .\terraform\run_deploy_with_tests.ps1 terraform
  #
  #   # Run from anywhere with an explicit path:
  #   .\terraform\run_deploy_with_tests.ps1 -TerraformRoot .\terraform
  #
  # Notes:
  # - The Terraform root must contain at least one *.tf file.
  # - This script writes a summary report and raw log into the Terraform root.
  [Parameter(Position = 0)]
  [Alias('Path')]
  [string]$TerraformRoot,

  [switch]$IncludeTerraformIntegrationTests,
  [switch]$ContinueOnUnitTestFailures,
  [switch]$Strict,
  [switch]$VerboseTerraformTest,
  [string]$ReportPath = ".\\catts-run-report.md",
  [string]$LogPath = ".\\catts-run.log"
)

$ErrorActionPreference = 'Stop'

class CattsAssertionException : System.Exception {
  CattsAssertionException([string]$message) : base($message) {}
}

function Write-Section([string]$Title) {
  Write-Host "" 
  Write-Host "============================================================" -ForegroundColor Cyan
  Write-Host $Title -ForegroundColor Cyan
  Write-Host "============================================================" -ForegroundColor Cyan
}

function Invoke-Checked([string]$Command) {
  Write-Host "`n> $Command" -ForegroundColor Gray
  Invoke-Expression $Command
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

function Invoke-LoggedChecked([string]$Command, [string]$LogFilePath, [ref]$CapturedLines) {
  Write-Host "`n> $Command" -ForegroundColor Gray

  # Capture stdout/stderr, stream it live, and append to a raw log.
  $null = (Invoke-Expression $Command 2>&1 |
    Tee-Object -FilePath $LogFilePath -Append |
    Tee-Object -Variable __cattsTmp |
    Out-Host)

  $CapturedLines.Value = @($__cattsTmp | ForEach-Object { "$_" })

  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

function Invoke-Logged([string]$Command, [string]$LogFilePath, [ref]$CapturedLines) {
  Write-Host "`n> $Command" -ForegroundColor Gray

  try {
    # Capture stdout/stderr, stream it live, and append to a raw log.
    $null = (Invoke-Expression $Command 2>&1 |
      Tee-Object -FilePath $LogFilePath -Append |
      Tee-Object -Variable __cattsTmp |
      Out-Host)

    $CapturedLines.Value = @($__cattsTmp | ForEach-Object { "$_" })
    return $LASTEXITCODE
  }
  catch {
    $global:LASTEXITCODE = 1
    $msg = "Failed to execute command. This is usually a missing tool or a PowerShell invocation error.`nCommand: $Command`nError: $($_.Exception.Message)"
    $CapturedLines.Value = @($msg)
    try { Add-Content -LiteralPath $LogFilePath -Value $msg -Encoding utf8 } catch { }
    return 1
  }
}

function Set-StepFailure([string]$Message, [ref]$HasFailures) {
  $HasFailures.Value = $true
  Write-Warning $Message
}

function Set-DownstreamSkipped([string]$Reason) {
  $msg = "(skipped) $Reason"

  if ($script:prePlanOut.Count -lt 1) { $script:prePlanOut = @($msg) }
  if ($script:applyOut.Count -lt 1)   { $script:applyOut   = @($msg) }
  if ($script:planOut.Count -lt 1)    { $script:planOut    = @($msg) }

  foreach ($cat in $script:unitCategories) {
    if ($script:unitOut[$cat].Count -lt 1) { $script:unitOut[$cat] = @($msg) }
  }
  foreach ($cat in $script:pyItCategories) {
    if ($script:tfItOut[$cat].Count -lt 1) { $script:tfItOut[$cat] = @($msg) }
    if ($script:pyOut[$cat].Count -lt 1)   { $script:pyOut[$cat]   = @($msg) }
  }
}

function Test-DirectoryExists([string]$RelativePath) {
  return (Test-Path -LiteralPath (Join-Path -Path $PWD -ChildPath $RelativePath))
}

function Invoke-TerraformTestDirectory([string]$RelativeTestDir, [string]$LogFilePath, [ref]$CapturedLines) {
  if (-not (Test-DirectoryExists $RelativeTestDir)) {
    Write-Warning "Skipping terraform test; directory not found: $RelativeTestDir"
    $CapturedLines.Value = @("(skipped) directory not found: $RelativeTestDir")
    return 0
  }

  $args = @(
    'terraform test',
    "-test-directory=`"$RelativeTestDir`"",
    '-no-color'
  )
  if ($VerboseTerraformTest) { $args += '-verbose' }
  return (Invoke-Logged ($args -join ' ') $LogFilePath $CapturedLines)
}

function Invoke-PytestDirectory([string]$RelativePytestDir, [string]$LogFilePath, [ref]$CapturedLines) {
  if (-not (Test-DirectoryExists $RelativePytestDir)) {
    Write-Warning "Skipping pytest; directory not found: $RelativePytestDir"
    $CapturedLines.Value = @("(skipped) directory not found: $RelativePytestDir")
    return 0
  }

  $pythonCmd = (Get-Command python -ErrorAction SilentlyContinue)
  if (-not $pythonCmd) {
    $msg = "python is not available on PATH. Install Python and ensure 'python' is on PATH before running Python integration tests."
    Write-Warning $msg
    $CapturedLines.Value = @($msg)
    return 1
  }

  # Preflight: ensure pytest is installed, but don't emit Python tracebacks to the console/log.
  $null = (python -c "import pytest" 2>$null)
  if ($LASTEXITCODE -ne 0) {
    $msg = "pytest is not available in the current Python environment. Install it (e.g. `pip install pytest`) and re-run."
    Write-Warning $msg
    $CapturedLines.Value = @($msg)
    return 1
  }

  $command = "python -m pytest -vv --tb=no `"$RelativePytestDir`""
  Write-Host "`n> $command" -ForegroundColor Gray

  # Capture stdout/stderr, stream it live, and append to a raw log.
  $null = (Invoke-Expression $command 2>&1 |
    Tee-Object -FilePath $LogFilePath -Append |
    Tee-Object -Variable __cattsPyTmp |
    Out-Host)

  $CapturedLines.Value = @($__cattsPyTmp | ForEach-Object { "$_" })

  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    Write-Warning "pytest exited with $exitCode. This does not stop the script; see $LogFilePath and $ReportPath."
  }

  return $exitCode
}

function Get-FirstMatch([string[]]$Lines, [string]$Pattern) {
  foreach ($line in $Lines) {
    if ($line -match $Pattern) {
      return $Matches
    }
  }
  return $null
}

function Get-PytestTotals([string[]]$Lines) {
  # Parses pytest summary lines in all formats, including failure cases:
  #   "===== 7 passed in 1.23s ====="           (all pass)
  #   "===== 2 failed, 5 passed in 1.23s ====="  (some fail)
  #   "===== 7 failed in 1.23s ====="            (all fail)
  #   "===== 3 errors in 0.05s ====="            (collection errors)
  foreach ($line in $Lines) {
    if ($line -match '^=+\s+.+\s+in\s+([0-9\.]+)s\s+=+$') {
      $seconds = $Matches[1]
      $passed = if ($line -match '(\d+)\s+passed') { $Matches[1] } else { '0' }
      $failed = if ($line -match '(\d+)\s+failed') { $Matches[1] } else { '0' }
      return @{ passed = $passed; failed = $failed; seconds = $seconds }
    }
  }
  return $null
}

function Write-ConsoleSummaryRow([string]$Step, [string]$Result, [string]$Detail) {
  $resultColor = switch ($Result) {
    { $_ -in @('OK', 'Success') } { 'Green' }
    'Failure' { 'Red' }
    'Skipped' { 'DarkYellow' }
    'Unknown' { 'Yellow' }
    default { 'Gray' }
  }

  Write-Host ("{0,-44} " -f $Step) -NoNewline
  Write-Host ("{0,-8} " -f $Result) -NoNewline -ForegroundColor $resultColor
  Write-Host $Detail
}

# Resolve the Terraform root.
# - Default: the current working directory where the script is invoked.
# - If user provides a relative path, resolve it relative to the invocation working directory.
$invocationCwd = (Get-Location).Path
$hasFailures = $false
$strictMode = [bool]$Strict
$skipReason = $null
$skipAll = $false

if ([string]::IsNullOrWhiteSpace($TerraformRoot)) {
  $terraformRoot = $invocationCwd
}
else {
  try {
    $candidatePath = if ([System.IO.Path]::IsPathRooted($TerraformRoot)) {
      $TerraformRoot
    }
    else {
      Join-Path -Path $invocationCwd -ChildPath $TerraformRoot
    }
    $terraformRoot = (Resolve-Path -LiteralPath $candidatePath -ErrorAction Stop).Path
  }
  catch {
    $msg = "TerraformRoot path could not be resolved: $TerraformRoot"
    Set-StepFailure $msg ([ref]$hasFailures)
    $terraformRoot = $invocationCwd
    $skipAll = $true
    $skipReason = $msg
  }
}

# Basic safety check: ensure the folder looks like a Terraform root.
$tfFiles = Get-ChildItem -LiteralPath $terraformRoot -Filter '*.tf' -File -ErrorAction SilentlyContinue
if (-not $tfFiles -or $tfFiles.Count -lt 1) {
  $msg = (
    "TerraformRoot does not look like a Terraform root (no *.tf files found): $terraformRoot`n" +
    "Fix: cd into the Terraform folder and re-run, or pass -TerraformRoot <path>."
  )
  Set-StepFailure $msg ([ref]$hasFailures)
  $terraformRoot = $invocationCwd
  $skipAll = $true
  $skipReason = 'invalid terraform root'
}

try {
  Set-Location $terraformRoot
}
catch {
  $msg = "Failed to set working directory to Terraform root: $terraformRoot"
  Set-StepFailure $msg ([ref]$hasFailures)
  $skipAll = $true
  $skipReason = $msg
}

# Reset log so each run is self-contained.
try {
  if (Test-Path -LiteralPath $LogPath) {
    Remove-Item -LiteralPath $LogPath -Force
  }
  New-Item -Path $LogPath -ItemType File -Force | Out-Null
}
catch {
  $msg = "Failed to initialize log file: $LogPath"
  Set-StepFailure $msg ([ref]$hasFailures)
  $skipAll = $true
  $skipReason = $msg
}

$scriptStart = Get-Date
$initOut = @()
$prePlanOut = @()
$applyOut = @()
$planOut = @()
$validateOut = @()
$overallExitCode = 0
$skipAfterUnitFailure = $false

# Dynamic category lists — populated by scanning the tests/ tree after Set-Location.
$unitCategories  = @()
$pyItCategories  = @()

# Per-category output/exit-code hashtables (keyed by category name).
$unitOut  = @{}
$unitExit = @{}
$pyOut    = @{}
$pyExit   = @{}
$tfItOut  = @{}

# ─── Discover test categories from the tests/ tree ───────────────────────────
# Done here (after Set-Location) so the paths are relative to the terraform root.
if (-not $skipAll) {
  $unitCategories = @(
    Get-ChildItem 'tests/unit-tests' -Directory -ErrorAction SilentlyContinue |
      Select-Object -ExpandProperty Name | Sort-Object
  )
  $pyItCategories = @(
    Get-ChildItem 'tests/integration-tests' -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -ne '_shared' } |
      Select-Object -ExpandProperty Name | Sort-Object
  )
  foreach ($cat in $unitCategories)  { $unitOut[$cat] = @(); $unitExit[$cat] = 0 }
  foreach ($cat in $pyItCategories)  { $pyOut[$cat]   = @(); $pyExit[$cat]   = 0; $tfItOut[$cat] = @() }
}

if (-not $skipAll) {
  Write-Section "CATTS: terraform init (ensure providers are ready before tests)"
  $initExit = Invoke-Logged 'terraform init -no-color' $LogPath ([ref]$initOut)
  if ($initExit -ne 0) {
    $skipReason = "terraform init failed (exit $initExit)"
    Set-StepFailure "$skipReason. Cannot run unit tests or apply without initialized providers." ([ref]$hasFailures)
    $skipAll = $true
    Set-DownstreamSkipped $skipReason
  }
}

if (-not $skipAll) {
  Write-Section "CATTS: terraform validate"
  $validateExit = Invoke-Logged 'terraform validate -no-color' $LogPath ([ref]$validateOut)
  if ($validateExit -ne 0) {
    $skipReason = "terraform validate failed (exit $validateExit)"
    Set-StepFailure "$skipReason. Fix configuration errors before running tests." ([ref]$hasFailures)
    $skipAll = $true
    Set-DownstreamSkipped $skipReason
  }
}

Write-Section "CATTS: Pre-apply unit tests (Terraform test framework)"
foreach ($cat in $unitCategories) {
  Write-Host "Running unit tests: tests/unit-tests/$cat" -ForegroundColor DarkGray
}

if ($skipAll) {
  $r = if ($skipReason) { $skipReason } else { 'preflight failure' }
  foreach ($cat in $unitCategories) { $unitOut[$cat] = @("(skipped) $r") }
  Set-DownstreamSkipped $r
}
else {
  foreach ($cat in $unitCategories) {
    $capturedLines = @()
    $unitExit[$cat] = Invoke-TerraformTestDirectory "tests/unit-tests/$cat" $LogPath ([ref]$capturedLines)
    $unitOut[$cat]  = $capturedLines
  }
}

$anyUnitFailed = $false
foreach ($v in $unitExit.Values) { if ($v -ne 0) { $anyUnitFailed = $true; break } }

if (-not $skipAll -and $anyUnitFailed) {
  $hasFailures = $true
  $skipReason = 'unit tests failed'

  if ($Strict) {
    $skipAfterUnitFailure = $true
    Write-Warning "One or more unit test suites failed. Skipping plan/apply/integration steps because -Strict was specified."
    Set-DownstreamSkipped $skipReason
  }
  elseif (-not $ContinueOnUnitTestFailures) {
    $skipAfterUnitFailure = $true
    Write-Warning "One or more unit test suites failed. Skipping plan/apply/integration steps. (Tip: re-run with -ContinueOnUnitTestFailures to still validate downstream steps.)"
    Set-DownstreamSkipped $skipReason
  }
  else {
    Write-Warning "One or more unit test suites failed, but continuing because -ContinueOnUnitTestFailures was specified."
  }
}

if (-not $skipAll -and -not $skipAfterUnitFailure) {
  Write-Section "CATTS: Pre-apply plan (terraform plan)"
  $prePlanExit = Invoke-Logged 'terraform plan -no-color' $LogPath ([ref]$prePlanOut)
  if ($prePlanExit -ne 0) {
    $skipReason = "terraform plan failed (exit $prePlanExit)"
    Set-StepFailure "$skipReason. Skipping apply/integration steps." ([ref]$hasFailures)
    $skipAfterUnitFailure = $true
    Set-DownstreamSkipped $skipReason
  }

  if (-not $skipAfterUnitFailure) {
    Write-Section "CATTS: Terraform apply"
    $applyExit = Invoke-Logged 'terraform apply -auto-approve -no-color' $LogPath ([ref]$applyOut)
    if ($applyExit -ne 0) {
      $skipReason = "terraform apply failed (exit $applyExit)"
      Set-StepFailure "$skipReason. Skipping post-apply steps." ([ref]$hasFailures)
      $skipAfterUnitFailure = $true
      Set-DownstreamSkipped $skipReason
    }
  }

  if (-not $skipAfterUnitFailure) {
    Write-Section "CATTS: Post-apply drift check (terraform plan)"
    $postPlanExit = Invoke-Logged 'terraform plan -no-color' $LogPath ([ref]$planOut)
    if ($postPlanExit -ne 0) {
      Set-StepFailure "post-apply terraform plan failed (exit $postPlanExit)." ([ref]$hasFailures)
    }
  }

  if ($IncludeTerraformIntegrationTests) {
    Write-Section "CATTS: Post-apply Terraform integration tests (EXPECTED TO FAIL if resources already exist)"
    foreach ($cat in $pyItCategories) {
      Write-Host "Running Terraform integration tests: tests/integration-tests/$cat" -ForegroundColor DarkGray
      $capturedLines = @()
      try {
        $exitCode = Invoke-TerraformTestDirectory "tests/integration-tests/$cat" $LogPath ([ref]$capturedLines)
        if ($exitCode -ne 0) { $hasFailures = $true }
      }
      catch {
        $hasFailures = $true
        Write-Warning "Terraform integration tests ($cat) threw an error: $($_.Exception.Message)"
      }
      $tfItOut[$cat] = $capturedLines
    }
  }

  Write-Section "CATTS: Post-apply validation (Python/pytest)"
  Write-Host "Tip: if pytest isn't installed, run:  python -m pip install --user pytest" -ForegroundColor DarkGray
  foreach ($cat in $pyItCategories) {
    $capturedLines = @()
    $pyExit[$cat] = Invoke-PytestDirectory ".\tests\integration-tests\$cat" $LogPath ([ref]$capturedLines)
    $pyOut[$cat]  = $capturedLines
  }

  $anyPyFailed = $false
  foreach ($v in $pyExit.Values) { if ($v -ne 0) { $anyPyFailed = $true; break } }
  if ($anyPyFailed) { $hasFailures = $true }
}

Write-Section "CATTS: Summary report"
$scriptEnd = Get-Date
$duration = New-TimeSpan -Start $scriptStart -End $scriptEnd

$validateSuccessLine = ($validateOut | Where-Object { $_ -match 'Success!' } | Select-Object -First 1)
$applySummaryLine    = ($applyOut  | Where-Object { $_ -match '^Apply complete! Resources:' } | Select-Object -First 1)
$applyNoChangesLine = ($applyOut | Where-Object { $_ -match '^No changes\.' } | Select-Object -First 1)
$planNoChangesLine  = ($planOut  | Where-Object { $_ -match '^No changes\.' } | Select-Object -First 1)

$reportLines = @()
$reportLines += "# CATTS Deploy + Tests Report"
$reportLines += ""
$reportLines += "- Time: $($scriptStart.ToString('yyyy-MM-dd HH:mm:ss'))"
$reportLines += "- Duration: $([int]$duration.TotalMinutes)m $($duration.Seconds)s"
$reportLines += "- Terraform root: $terraformRoot"
$reportLines += "- Raw log: $LogPath"
$reportLines += ""
$reportLines += "| Step | Result | Key line |"
$reportLines += "|---|---|---|"

# terraform validate
if ($validateOut.Count -gt 0 -and $validateOut[0] -like '(skipped)*') {
  $reportLines += "| Terraform validate | Skipped | $($validateOut[0]) |"
}
elseif ($validateSuccessLine) {
  $reportLines += "| Terraform validate | OK | $validateSuccessLine |"
}
elseif ($validateOut.Count -gt 0) {
  $result = if ($validateExit -eq 0) { 'OK' } else { 'Failure' }
  $reportLines += "| Terraform validate | $result | (see raw log) |"
}
else {
  $reportLines += "| Terraform validate | Unknown | (no output captured) |"
}

# Unit test rows — one per discovered category
foreach ($cat in $unitCategories) {
  $out     = $unitOut[$cat]
  $summary = (Get-FirstMatch $out '^(Success|Failure)!\s+(?<passed>\d+)\s+passed,\s+(?<failed>\d+)\s+failed')
  if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
    $reportLines += "| Unit tests (pre-apply, $cat) | Skipped | $($out[0]) |"
  }
  elseif ($summary) {
    $reportLines += "| Unit tests (pre-apply, $cat) | $($summary[1]) | $($summary[0]) |"
  }
  else {
    $reportLines += "| Unit tests (pre-apply, $cat) | (see raw log) | (could not parse terraform test summary) |"
  }
}

if ($prePlanOut.Count -gt 0) {
  if ($prePlanOut[0] -like '(skipped)*') {
    $reportLines += "| Terraform plan (pre-apply) | Skipped | $($prePlanOut[0]) |"
  }
  else {
    $prePlanNoChangesLine = ($prePlanOut | Where-Object { $_ -match '^No changes\.' } | Select-Object -First 1)
    if ($prePlanNoChangesLine) {
      $reportLines += "| Terraform plan (pre-apply) | OK | $prePlanNoChangesLine |"
    }
    else {
      $reportLines += "| Terraform plan (pre-apply) | OK | (see raw log) |"
    }
  }
}
else {
  $reportLines += "| Terraform plan (pre-apply) | Unknown | (no output captured) |"
}

if ($applyOut.Count -gt 0 -and $applyOut[0] -like '(skipped)*') {
  $reportLines += "| Terraform apply | Skipped | $($applyOut[0]) |"
}
elseif ($applySummaryLine) {
  $reportLines += "| Terraform apply | OK | $applySummaryLine |"
}
elseif ($applyNoChangesLine) {
  $reportLines += "| Terraform apply | OK | $applyNoChangesLine |"
}
else {
  $reportLines += "| Terraform apply | Unknown | (could not find apply summary line) |"
}

if ($planOut.Count -gt 0 -and $planOut[0] -like '(skipped)*') {
  $reportLines += "| Terraform plan (post-apply) | Skipped | $($planOut[0]) |"
}
elseif ($planNoChangesLine) {
  $reportLines += "| Terraform plan (post-apply) | OK | $planNoChangesLine |"
}
else {
  $reportLines += "| Terraform plan (post-apply) | Unknown | (could not find plan summary line) |"
}

# Python IT rows — one per discovered category
foreach ($cat in $pyItCategories) {
  $out      = $pyOut[$cat]
  $exitCode = $pyExit[$cat]
  $totals   = (Get-PytestTotals $out)
  if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
    $reportLines += "| Python post-apply validation ($cat) | Skipped | $($out[0]) |"
  }
  elseif ($totals) {
    $failedCount = if ($totals['failed']) { $totals['failed'] } else { '0' }
    $result = if ($exitCode -eq 0) { 'OK' } else { 'Failure' }
    $reportLines += "| Python post-apply validation ($cat) | $result | $($totals['passed']) passed, $failedCount failed in $($totals['seconds'])s |"
  }
  else {
    $result = if ($exitCode -eq 0) { 'OK' } else { 'Failure' }
    $reportLines += "| Python post-apply validation ($cat) | $result | pytest exit code $exitCode (see raw log) |"
  }
}

# Terraform IT rows (optional) — one per discovered category
if ($IncludeTerraformIntegrationTests) {
  foreach ($cat in $pyItCategories) {
    $out     = $tfItOut[$cat]
    $summary = (Get-FirstMatch $out '^(Success|Failure)!\s+(?<passed>\d+)\s+passed,\s+(?<failed>\d+)\s+failed')
    if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
      $reportLines += "| Terraform integration tests ($cat) | Skipped | $($out[0]) |"
    }
    elseif ($summary) {
      $reportLines += "| Terraform integration tests ($cat) | $($summary[1]) | $($summary[0]) |"
    }
    else {
      $reportLines += "| Terraform integration tests ($cat) | (see raw log) | Often fails if RG/resources already exist (fresh test state) |"
    }
  }
}

$reportText = ($reportLines -join "`r`n") + "`r`n"
try {
  Set-Content -LiteralPath $ReportPath -Value $reportText -Encoding utf8
  Write-Host "Wrote report to: $ReportPath" -ForegroundColor Green
  Write-Host "Wrote raw log to: $LogPath" -ForegroundColor Green
}
catch {
  $msg = "Failed to write report/log. ReportPath=$ReportPath LogPath=$LogPath"
  Set-StepFailure $msg ([ref]$hasFailures)
}

Write-Section "CATTS: Console summary"
Write-Host "Terraform root: $terraformRoot" -ForegroundColor DarkGray
Write-Host "Report: $ReportPath" -ForegroundColor DarkGray
Write-Host "Log:    $LogPath" -ForegroundColor DarkGray
Write-Host ""
Write-Host ("{0,-44} {1,-8} {2}" -f 'Step', 'Result', 'Detail') -ForegroundColor Cyan
Write-Host ("{0,-44} {1,-8} {2}" -f '----', '------', '------') -ForegroundColor Cyan

# terraform validate
if ($validateOut.Count -gt 0 -and $validateOut[0] -like '(skipped)*') {
  Write-ConsoleSummaryRow 'Terraform validate' 'Skipped' $validateOut[0]
}
elseif ($validateSuccessLine) {
  Write-ConsoleSummaryRow 'Terraform validate' 'OK' $validateSuccessLine
}
elseif ($validateOut.Count -gt 0) {
  $result = if ($validateExit -eq 0) { 'OK' } else { 'Failure' }
  Write-ConsoleSummaryRow 'Terraform validate' $result '(see raw log)'
}
else {
  Write-ConsoleSummaryRow 'Terraform validate' 'Unknown' '(no output captured)'
}

# Unit tests — one row per discovered category
foreach ($cat in $unitCategories) {
  $out     = $unitOut[$cat]
  $summary = (Get-FirstMatch $out '^(Success|Failure)!\s+(?<passed>\d+)\s+passed,\s+(?<failed>\d+)\s+failed')
  if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
    Write-ConsoleSummaryRow "Unit tests ($cat)" 'Skipped' $out[0]
  }
  elseif ($summary) {
    $detail = "$($summary['passed']) passed, $($summary['failed']) failed"
    Write-ConsoleSummaryRow "Unit tests ($cat)" $summary[1] $detail
  }
  else {
    Write-ConsoleSummaryRow "Unit tests ($cat)" 'Unknown' 'See raw log'
  }
}

# Pre-apply plan
if ($prePlanOut.Count -gt 0) {
  if ($prePlanOut[0] -like '(skipped)*') {
    Write-ConsoleSummaryRow 'Terraform plan (pre-apply)' 'Skipped' $prePlanOut[0]
  }
  else {
    $line = ($prePlanOut | Where-Object { $_ -match '^No changes\.' } | Select-Object -First 1)
    if (-not $line) { $line = '(see raw log)' }
    Write-ConsoleSummaryRow 'Terraform plan (pre-apply)' 'OK' $line
  }
}
else {
  Write-ConsoleSummaryRow 'Terraform plan (pre-apply)' 'Unknown' '(no output captured)'
}

# Apply
if ($applyOut.Count -gt 0 -and $applyOut[0] -like '(skipped)*') {
  Write-ConsoleSummaryRow 'Terraform apply' 'Skipped' $applyOut[0]
}
elseif ($applySummaryLine) {
  Write-ConsoleSummaryRow 'Terraform apply' 'OK' $applySummaryLine
}
elseif ($applyNoChangesLine) {
  Write-ConsoleSummaryRow 'Terraform apply' 'OK' $applyNoChangesLine
}
else {
  Write-ConsoleSummaryRow 'Terraform apply' 'Unknown' 'See raw log'
}

# Post-apply drift plan
if ($planOut.Count -gt 0 -and $planOut[0] -like '(skipped)*') {
  Write-ConsoleSummaryRow 'Terraform plan (post-apply)' 'Skipped' $planOut[0]
}
elseif ($planNoChangesLine) {
  Write-ConsoleSummaryRow 'Terraform plan (post-apply)' 'OK' $planNoChangesLine
}
elseif ($planOut.Count -gt 0) {
  Write-ConsoleSummaryRow 'Terraform plan (post-apply)' 'OK' '(see raw log)'
}
else {
  Write-ConsoleSummaryRow 'Terraform plan (post-apply)' 'Unknown' '(no output captured)'
}

# Terraform IT rows (optional) — one per discovered category
if ($IncludeTerraformIntegrationTests) {
  foreach ($cat in $pyItCategories) {
    $out     = $tfItOut[$cat]
    $summary = (Get-FirstMatch $out '^(Success|Failure)!\s+(?<passed>\d+)\s+passed,\s+(?<failed>\d+)\s+failed')
    if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
      Write-ConsoleSummaryRow "TF integration tests ($cat)" 'Skipped' $out[0]
    }
    elseif ($summary) {
      $detail = "$($summary['passed']) passed, $($summary['failed']) failed"
      Write-ConsoleSummaryRow "TF integration tests ($cat)" $summary[1] $detail
    }
    else {
      Write-ConsoleSummaryRow "TF integration tests ($cat)" 'Unknown' 'See raw log'
    }
  }
}
else {
  Write-ConsoleSummaryRow 'TF integration tests' 'Skipped' 'Use -IncludeTerraformIntegrationTests'
}

# Python validation — one row per discovered category
foreach ($cat in $pyItCategories) {
  $out      = $pyOut[$cat]
  $exitCode = $pyExit[$cat]
  $totals   = (Get-PytestTotals $out)
  if ($out.Count -gt 0 -and $out[0] -like '(skipped)*') {
    Write-ConsoleSummaryRow "Python validation ($cat)" 'Skipped' $out[0]
  }
  elseif ($totals) {
    $failedCount = if ($totals['failed']) { $totals['failed'] } else { '0' }
    $result = if ($exitCode -eq 0) { 'OK' } else { 'Failure' }
    Write-ConsoleSummaryRow "Python validation ($cat)" $result "$($totals['passed']) passed, $failedCount failed"
  }
  else {
    $result = if ($exitCode -eq 0) { 'OK' } else { 'Failure' }
    Write-ConsoleSummaryRow "Python validation ($cat)" $result "pytest exit code $exitCode"
  }
}

Write-Section "DONE"
if (-not $hasFailures) {
  Write-Host "All requested steps completed." -ForegroundColor Green
}
else {
  Write-Warning "Completed with failures. See: $ReportPath"
}

if ($strictMode -and $hasFailures) {
  throw [CattsAssertionException]::new("CATTS detected one or more failures. See report: $ReportPath")
}

exit 0
