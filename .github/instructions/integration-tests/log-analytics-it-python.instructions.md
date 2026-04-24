---
description: "Use when generating Python post-apply integration tests for Azure Log Analytics Workspace that validate real Azure state."
---

# CATTS — Log Analytics Workspace integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Azure Log Analytics Workspace** that run **after** `terraform apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate Log Analytics Workspace-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/log-analytics/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/log-analytics/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `log_analytics_workspace_id` (best), OR
  - `log_analytics_workspace_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- By ID: `az monitor log-analytics workspace show --ids <workspace_id>`
- By name: `az monitor log-analytics workspace show --workspace-name <name> --resource-group <rg>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations as separate `test_*` functions:

### Identity / policy

- `test_log_analytics_exists`: Workspace can be retrieved (non-null response)
- `test_log_analytics_name_nonempty`: `name` field is non-empty
- `test_log_analytics_location_nonempty`: `location` is non-empty
- `test_log_analytics_location_allowed`: `location` is in allowed list — only if English policy defines **Allowed locations** (normalize: lower + remove spaces on both sides)
- `test_log_analytics_naming_convention`: `name` matches naming regex — only if English policy defines a **Naming convention**
- `test_log_analytics_required_tags`: required tag keys exist on `tags` — only if English policy defines **Required tags (keys)**

### SKU / retention

- `test_log_analytics_sku_nonempty`: `sku.name` is non-empty
- `test_log_analytics_sku_recommended`: `sku.name` is `"PerGB2018"` — emit a warning-style assertion message (not a hard failure) if a legacy SKU is found; adapt based on whether the English policy mandates a specific SKU
- `test_log_analytics_retention_days_minimum`: `retentionInDays` >= 30

### Workspace ID (needed for diagnostic settings)

- `test_log_analytics_workspace_id_nonempty`: `customerId` (the workspace ID / GUID) is non-empty — this is the ID used in diagnostic setting configurations

## File naming (required)

Under `<terraform_root>/tests/integration-tests/log-analytics/`:

- `test_log_analytics_basic.py` (always)

## Feature coverage checklist

Generate one dedicated `test_*` function per item above. Make every failure message actionable:

```
f"Log Analytics Workspace '{name}' retentionInDays={actual}. Expected >= 30."
```

## Policy behavior (required)

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## Minimum output contract

When finished, `test_log_analytics_basic.py` must include at minimum:

- `test_log_analytics_exists`
- `test_log_analytics_sku_nonempty`
- `test_log_analytics_retention_days_minimum`
