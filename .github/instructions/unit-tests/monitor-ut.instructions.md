---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Monitor resources (azurerm_monitor_diagnostic_setting, azurerm_monitor_action_group, azurerm_monitor_metric_alert, azurerm_monitor_activity_log_alert) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Azure Monitor unit test generation (Terraform-only)

## Scope

This category covers Azure Monitor observability and alerting resources:

- `azurerm_monitor_diagnostic_setting`
- `azurerm_monitor_action_group`
- `azurerm_monitor_metric_alert`
- `azurerm_monitor_activity_log_alert`
- `azurerm_monitor_autoscale_setting` (assert when present)

**Out of scope:** Azure Monitor Workbooks, dashboards, data collection rules.

## Scope boundaries (must follow)

- ONLY create tests for Monitor-related objects listed above.
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/monitor/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/monitor/`

## What to assert for `azurerm_monitor_diagnostic_setting`

For each discovered diagnostic setting resource address `azurerm_monitor_diagnostic_setting.<NAME>`:

**Required fields:**

- `name` is non-empty
- `target_resource_id` is non-empty

**Sink — at least one must be configured:**

- At least one of the following is non-empty:
  - `log_analytics_workspace_id`
  - `storage_account_id`
  - `eventhub_authorization_rule_id`
  - `partner_solution_id`

Assert each present sink individually (one assert per run).

**Log/metric categories:**

- At least one `enabled_log` block or `metric` block is defined in the config (proves the setting is not empty)
- For each `enabled_log` block: `category` or `category_group` is non-empty
- For each `metric` block: `category` is non-empty and `enabled` is `true`

## What to assert for `azurerm_monitor_action_group`

For each discovered action group resource address `azurerm_monitor_action_group.<NAME>`:

**Identity / naming:**

- `name` is non-empty
- `name` matches naming policy ONLY if the naming convention is configured in the English policy
- `resource_group_name` is non-empty
- `short_name` is non-empty (Azure display name; max 12 chars)
- `short_name` length <= 12

**Receivers — at least one must be configured:**

Assert that at least one receiver block is present. Check for (use the first non-empty group found):

- `email_receiver`
- `webhook_receiver`
- `arm_role_receiver`
- `azure_function_receiver`
- `logic_app_receiver`
- `sms_receiver`
- `voice_receiver`
- `event_hub_receiver`
- `itsm_receiver`
- `automation_runbook_receiver`
- `azure_app_push_receiver`

**Tags:**

- If the English policy defines **Required tags (keys)**: assert each required tag key exists in the `tags` map.

## What to assert for `azurerm_monitor_metric_alert`

For each discovered metric alert resource address `azurerm_monitor_metric_alert.<NAME>`:

**Identity:**

- `name` is non-empty
- `resource_group_name` is non-empty

**Configuration:**

- `enabled` is `true`
- `scopes` list is non-empty
- At least one `criteria` block is defined
- For each `criteria` block:
  - `metric_name` is non-empty
  - `aggregation` is non-empty
  - `operator` is non-empty
  - `threshold` is present (assert it is a number; do not assert specific threshold values)
- `window_size` is non-empty when set
- `frequency` is non-empty when set

**Action:**

- If `action` blocks are present: `action_group_id` is non-empty for each

## What to assert for `azurerm_monitor_activity_log_alert`

For each discovered activity log alert resource address `azurerm_monitor_activity_log_alert.<NAME>`:

**Identity:**

- `name` is non-empty
- `resource_group_name` is non-empty

**Configuration:**

- `enabled` is `true`
- `scopes` list is non-empty
- At least one `criteria` block is defined
- For each `criteria` block: `operation_name` or `category` is non-empty

**Action:**

- If `action` blocks are present: `action_group_id` is non-empty for each

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/monitor/`:

- `naming.tftest.hcl` — action group naming, short_name, resource group invariants (always, even if only action groups are present)
- `config.tftest.hcl` — diagnostic setting sink, alert enabled state, criteria presence (always)

## Test names (required)

Use these canonical `run` block names:

### In `naming.tftest.hcl` (one assert per run):

- `run "action_group_name_nonempty" { command = plan }`
- `run "action_group_name_matches_convention" { command = plan }` (only if naming convention is configured)
- `run "action_group_resource_group_nonempty" { command = plan }`
- `run "action_group_short_name_nonempty" { command = plan }`
- `run "action_group_short_name_max_length" { command = plan }`

### In `config.tftest.hcl` (one assert per run):

- `run "diagnostic_setting_name_nonempty" { command = plan }`
- `run "diagnostic_setting_target_resource_id_nonempty" { command = plan }`
- `run "diagnostic_setting_sink_configured" { command = plan }`
- `run "metric_alert_enabled" { command = plan }`
- `run "metric_alert_criteria_present" { command = plan }`
- `run "activity_log_alert_enabled" { command = plan }`
- `run "action_group_receiver_configured" { command = plan }`

If multiple resources of the same type exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/monitor/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered Monitor resource
