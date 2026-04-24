# CATTS — Customer Setup & Usage Guide

CATTS (GitHub Copilot Automatic Terraform Testing Suite) uses VS Code Copilot agent
mode to scan your Terraform folders and generate two layers of tests automatically:

- **Terraform unit tests** (`tests/unit-tests/**/*.tftest.hcl`) — run `terraform test`
  with a mock provider; no Azure credentials required.
- **Python integration tests** (`tests/integration-tests/**/*.py`) — run with `pytest`
  after `terraform apply`; validate live Azure resource state.

---

## Centralized Org Deployment

For organizations with multiple teams, the recommended model is a single **central CATTS
config repo** that holds the org-wide `.github/` package (with shared policies, agents, and
instructions). Individual team repos start from that baseline and can extend it with their
own customizations — updates from the central repo are always **merged**, never overwritten,
so team-specific changes are preserved.

### Set up the central repo

1. Fork or clone `Automated_IOC_Testing` into your org (e.g. `myorg/catts-config`).
2. Fill in org-wide policies — see **Step 2** below.
3. Commit and push. This repo is the single source of truth for shared policy and agents.

### Bootstrap a new team repo from the central repo

```powershell
# Clone the central config repo locally
git clone https://github.com/myorg/catts-config.git

# Copy .github/ into the new team repo (assumes team-repo is already cloned alongside)
Copy-Item -Path catts-config\.github -Destination .\team-repo\ -Recurse

cd team-repo
git add .github
git commit -m "Bootstrap CATTS from central config"
git push
```

### Merge central-repo updates into an existing team repo

When shared policies or agents change in the central repo, merge the updated files into
each team repo **selectively** — do not bulk-copy, as teams may have customized individual
instruction files.

```powershell
# Add the central config repo as a remote (one-time setup per team repo)
git remote add catts-config https://github.com/myorg/catts-config.git
git fetch catts-config

# Review what changed in the central repo since your last merge
git diff HEAD catts-config/main -- .github/

# Cherry-pick specific files you want to adopt (example: updated policies)
git checkout catts-config/main -- .github/instructions/global/policies.instructions.md

# Or merge the entire .github/ tree and resolve conflicts where teams have customized files
git checkout -b merge/catts-update
git merge -X ours catts-config/main --allow-unrelated-histories --no-commit
# Review and resolve any conflicts, then:
git commit -m "Merge CATTS update from central config"
git push origin merge/catts-update
# Open a PR for team review before merging to main
```

> **Why merge, not overwrite?** Each team repo can extend or override individual
> instruction files (e.g. add team-specific naming rules or custom agents). A bulk copy
> from the central repo would silently discard those customizations. Always review diffs
> before committing central-repo changes into a team repo.

---

## Prerequisites

| Tool           | Minimum version    | Notes                                                    |
| -------------- | ------------------ | -------------------------------------------------------- |
| VS Code        | Latest stable      | Copilot extension required                               |
| GitHub Copilot | Agent mode enabled | Requires Copilot licence                                 |
| Terraform      | >= 1.9             | Must be on `PATH`                                        |
| Python         | >= 3.11            | Must be on `PATH` as `python`                            |
| pytest         | Any recent         | `pip install pytest`                                     |
| Azure CLI      | Any recent         | `az login` must succeed before running integration tests |

---

## Step 1 — Place the `.github/` folder at your workspace root

Copy the entire `.github/` folder into the root of the VS Code workspace that
contains your Terraform folder(s). VS Code automatically discovers agents,
instructions, and prompts from `.github/`.

Expected layout after placement:

```
<your-workspace>/
  .github/
    agents/
    instructions/
    prompts/
    run_deploy_with_tests.ps1   <- deploy this to each Terraform folder (see Step 3)
    copilot-instructions.md
  <your-terraform-folder>/
    main.tf
    ...
```

---

## Step 2 — Configure company policies (optional but recommended)

Open `.github/instructions/global/policies.instructions.md` and fill in the
**Enforceable rules (English)** section with your organisation's naming
convention, required tag keys, and allowed Azure regions.

Example (edit the values on the right side only — keep the labels identical):

```
- Naming convention (human-readable): `<env>-<resource>-<region>-<instance>`
- Required tags (keys): `Environment`, `Owner`, `CostCenter`
- Allowed locations: `eastus2`, `westeurope`
```

Leave a value blank if your org has no policy for that dimension — CATTS will
skip that assertion rather than inventing rules.

---

## Step 3 — Deploy the run script to each Terraform folder

Copy `.github/run_deploy_with_tests.ps1` into **each Terraform root folder** you
want to include in automated testing:

```powershell
# Example — copy into two Terraform roots
Copy-Item .github\run_deploy_with_tests.ps1 .\terraform\
Copy-Item .github\run_deploy_with_tests.ps1 .\terraform-spoke\
```

The script runs the full test lifecycle from within a Terraform root:

1. `terraform init` + `terraform validate`
2. Terraform unit tests (`terraform test`, pre-apply, mock provider)
3. `terraform plan` -> `terraform apply`
4. Post-apply drift check (`terraform plan`)
5. Python/pytest integration tests (validates live Azure state)

**Usage:**

```powershell
# Run from inside the Terraform folder (most common):
cd .\terraform
.\run_deploy_with_tests.ps1

# Continue past unit-test failures to still run plan/apply:
.\run_deploy_with_tests.ps1 -ContinueOnUnitTestFailures

# Include Terraform-native integration tests in addition to pytest:
.\run_deploy_with_tests.ps1 -IncludeTerraformIntegrationTests

# Fail the entire run if any unit test fails (CI strict mode):
.\run_deploy_with_tests.ps1 -Strict
```

After each run the script writes two files into the Terraform root:

- `catts-run-report.md` — human-readable Markdown summary table
- `catts-run.log` — raw combined stdout/stderr log

---

## Step 4 — Generate tests with the CATTS orchestrator

1. Open VS Code Chat (`Ctrl+Alt+I`).
2. Switch to **Agent mode** (drop-down in the chat input bar).
3. Select the **`orchestrator`** agent.
4. Run:

```
Generate CATTS tests for <your-terraform-folder>
```

or use the `#catts-generate` prompt and pass your Terraform folder as the argument.

CATTS will:

- Scan all `*.tf` files in the folder (skipping `.terraform/`)
- Map detected resource types to test categories
- Read per-category instruction files
- Write unit and integration test files directly under `tests/`

---

## Step 5 — Iterate

| Goal                                      | Action                                                       |
| ----------------------------------------- | ------------------------------------------------------------ |
| Add or change a policy rule               | Edit `.github/instructions/global/policies.instructions.md`  |
| Clean old generated tests                 | Use the `#catts-clean` prompt with the Terraform folder path |
| Re-generate after infra or policy changes | Run the orchestrator again to create fresh tests             |

---

## Safety rules enforced by CATTS

- CATTS **never** modifies `.tf` infrastructure files.
- Tests are written **only** under `<terraform_root>/tests/`.
- CATTS **never** runs `terraform apply` or deploys infrastructure itself — the
  `run_deploy_with_tests.ps1` script does that when you invoke it explicitly.
