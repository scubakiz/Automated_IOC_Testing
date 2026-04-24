---
description: "Use when generating Python post-apply integration tests for Azure Monitor resources that validate real Azure state."
---

# CATTS — Azure Monitor integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Azure Monitor** resources that run **after** `terraform apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope

- `azurerm_monitor_diagnostic_setting`
- `azurerm_monitor_action_group`
- `azurerm_monitor_metric_alert`
- `azurerm_monitor_activity_log_alert`

**Out of scope:** Workbooks, dashboards, data collection rules.

## Scope boundaries

- ONLY validate Monitor-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/monitor/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/monitor/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - For action groups: `monitor_action_group_id` OR `monitor_action_group_name` + `resource_group_name`
  - For metric alerts: `monitor_metric_alert_id` OR name + RG
  - For diagnostic settings: `monitor_diagnostic_setting_id` OR target resource ID + setting name
- If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- Action group: `az monitor action-group show --ids <id>` or `--name <name> --resource-group <rg>`
- Metric alert: `az monitor metrics alert show --ids <id>` or `--name <name> --resource-group <rg>`
- Activity log alert: `az monitor activity-log alert show --ids <id>` or `--name <name> --resource-group <rg>`
- Diagnostic setting: `az monitor diagnostic-settings show --ids <diagnostic_setting_id>` or `--name <name> --resource <target_resource_id>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations as separate `test_*` functions, organized by resource type.

### Diagnostic settings

- `test_diagnostic_setting_exists`: can be retrieved (non-null response)
- `test_diagnostic_setting_name_nonempty`: `name` is non-empty
- `test_diagnostic_setting_sink_configured`: at least one of `workspaceId`, `storageAccountId`, `eventHubAuthorizationRuleId` is non-null and non-empty
- `test_diagnostic_setting_logs_or_metrics_present`: `logs` list is non-empty OR `metrics` list is non-empty

### Action groups

- `test_action_group_exists`: can be retrieved (non-null response)
- `test_action_group_name_nonempty`: `name` is non-empty
- `test_action_group_short_name_nonempty`: `properties.groupShortName` is non-empty
- `test_action_group_short_name_max_length`: `len(properties.groupShortName)` <= 12
- `test_action_group_receiver_configured`: at least one receiver list (`emailReceivers`, `webhookReceivers`, `armRoleReceivers`, `azureFunctionReceivers`, etc.) is non-empty
- `test_action_group_enabled`: `properties.enabled` is `true`
- `test_action_group_naming_convention`: `name` matches naming regex — only if English policy defines a **Naming convention**
- `test_action_group_required_tags`: required tag keys exist — only if English policy defines **Required tags (keys)**

### Metric alerts

- `test_metric_alert_exists`: can be retrieved (non-null response)
- `test_metric_alert_name_nonempty`: `name` is non-empty
- `test_metric_alert_enabled`: `properties.enabled` is `true`
- `test_metric_alert_scopes_nonempty`: `properties.scopes` list is non-empty
- `test_metric_alert_criteria_present`: `properties.criteria` is non-null and non-empty
- `test_metric_alert_severity_set`: `properties.severity` is present (0–4; do not assert a specific value unless policy mandates it)

### Activity log alerts

- `test_activity_log_alert_exists`: can be retrieved (non-null response)
- `test_activity_log_alert_name_nonempty`: `name` is non-empty
- `test_activity_log_alert_enabled`: `properties.enabled` is `true`
- `test_activity_log_alert_scopes_nonempty`: `properties.scopes` list is non-empty
- `test_activity_log_alert_condition_present`: `properties.condition` is non-null

## File naming (required)

Under `<terraform_root>/tests/integration-tests/monitor/`:

- `test_monitor_basic.py` (always — consolidate all resource types into one file unless the count makes it unwieldy)
- `test_monitor_alerts.py` (optional — if many alert resources exist, split alert tests here)

## Feature coverage checklist

Generate one dedicated `test_*` function per item above. Only generate functions for resource types that are actually present (detected via Terraform outputs or `.tf` scan). Make every failure message actionable:

```
f"Action group '{name}' has no receivers configured. At least one receiver is required."
```

## Policy behavior (required)

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## Minimum output contract

When finished, `test_monitor_basic.py` must include at minimum (for each resource type present):

- Existence test
- Enabled-state test (for alerts and action groups)
- Sink or receiver configuration test (for diagnostic settings and action groups)
