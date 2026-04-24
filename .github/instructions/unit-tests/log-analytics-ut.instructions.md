---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Log Analytics Workspace (azurerm_log_analytics_workspace) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Log Analytics Workspace unit test generation (Terraform-only)

## Scope boundaries (must follow)

- ONLY create tests for Log Analytics Workspace-related objects.
  - Direct resources: `azurerm_log_analytics_workspace`
  - Sub-resources (assert when present): `azurerm_log_analytics_solution`, `azurerm_log_analytics_saved_search`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/log-analytics/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/log-analytics/`

## What to assert for `azurerm_log_analytics_workspace`

For each discovered workspace resource address `azurerm_log_analytics_workspace.<NAME>`:

**Identity / naming:**

- `name` is non-empty
- `name` matches naming policy ONLY if the naming convention is configured in the English policy
- `location` is non-empty
- `location` is in the allowed list ONLY if allowed locations are configured in the English policy
- `resource_group_name` is non-empty

**SKU:**

- `sku` is non-empty
- `sku` is `"PerGB2018"` — this is the modern recommended SKU; generate a comment if a legacy SKU is detected (e.g., `"Free"`, `"Standard"`, `"Premium"`, `"PerNode"`, `"CapacityReservation"`)

**Retention:**

- `retention_in_days` is >= 30 (minimum meaningful retention for operational use; Azure minimum is 7)

**Internet access flags (assert only when explicitly set in config):**

- `internet_ingestion_enabled` is non-empty when set
- `internet_query_enabled` is non-empty when set

**Tags:**

- If the English policy defines **Required tags (keys)**: assert each required tag key exists in the `tags` map.

## What to assert for sub-resources (only when present in the Terraform config)

### `azurerm_log_analytics_solution.<NAME>`

- `solution_name` is non-empty
- `workspace_resource_id` is non-empty
- `workspace_name` is non-empty
- `plan[0].publisher` is non-empty
- `plan[0].product` is non-empty

### `azurerm_log_analytics_saved_search.<NAME>`

- `name` is non-empty
- `log_analytics_workspace_id` is non-empty
- `category` is non-empty
- `display_name` is non-empty
- `query` is non-empty

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/log-analytics/`:

- `naming.tftest.hcl` — name, location, resource group invariants (always)
- `config.tftest.hcl` — sku, retention, tags (always)

## Test names (required)

Use these canonical `run` block names:

### In `naming.tftest.hcl` (one assert per run):

- `run "log_analytics_name_nonempty" { command = plan }`
- `run "log_analytics_name_matches_convention" { command = plan }` (only if naming convention is configured)
- `run "log_analytics_resource_group_name_nonempty" { command = plan }`
- `run "log_analytics_location_nonempty" { command = plan }`
- `run "log_analytics_location_allowed" { command = plan }` (only if allowed locations are configured)

### In `config.tftest.hcl` (one assert per run):

- `run "log_analytics_sku_nonempty" { command = plan }`
- `run "log_analytics_sku_recommended" { command = plan }` (assert `sku == "PerGB2018"`)
- `run "log_analytics_retention_days_minimum" { command = plan }` (assert >= 30)
- `run "log_analytics_tags_required_keys" { command = plan }` (only if required tags are configured)

If multiple workspace resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/log-analytics/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_log_analytics_workspace` resource
