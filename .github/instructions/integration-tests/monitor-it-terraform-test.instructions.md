---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Monitor resources against a real Azure subscription."
---

# CATTS — Azure Monitor integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Azure Monitor** resources using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope

- `azurerm_monitor_diagnostic_setting`
- `azurerm_monitor_action_group`
- `azurerm_monitor_metric_alert`
- `azurerm_monitor_activity_log_alert`

**Out of scope:** Workbooks, dashboards, data collection rules.

## Scope boundaries

- ONLY validate Monitor-related resources listed above.
- DO NOT add unrelated resources to "help" assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/monitor/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/monitor/`

## Strategy

If resources are created directly in the Terraform root, assert on direct resource attributes.

If resources are created inside modules, prefer asserting via **outputs + data sources**.

## What to validate

### Diagnostic settings

- Resource ID is non-empty after apply
- Target resource ID is non-empty
- At least one sink is configured (log analytics workspace ID, storage account ID, or event hub authorization rule ID)
- At least one log category or metric is enabled

### Action groups

- Resource ID is non-empty after apply
- `name` is non-empty
- `short_name` is non-empty and <= 12 characters
- At least one receiver is configured

### Metric alerts

- Resource ID is non-empty after apply
- `enabled` is `true`
- At least one scope is configured
- At least one criteria is defined

### Activity log alerts

- Resource ID is non-empty after apply
- `enabled` is `true`
- At least one scope is configured

**Policy-driven (add when configured in English policy):**

- Naming convention: action group name matches derived regex
- Required tags: required tag keys exist (if outputs/data provide tags)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/monitor/`:

- `apply_and_validate.tftest.hcl` (always)

## Test names (required)

Use this canonical `run` block name in `apply_and_validate.tftest.hcl`:

- `run "apply" { command = apply }`

## Diagnostics requirement (must follow)

- Keep a single `run "apply" { command = apply }` to avoid redeploying per-check.
- Every `assert` MUST have a specific `error_message` that identifies the failing resource and property.
- Prefer multiple small asserts (each with its own message) over one compound boolean.
- CI visibility recommendation: use JUnit output:
  - `terraform test -junit-xml=tests/test-results.xml`

## Minimum output contract

When finished, include at least one `.tftest.hcl` file that:

- contains a `run` block with `command = apply`
- validates at least one Monitor resource property against Azure
- includes at minimum the diagnostic setting sink and action group receiver assertions (when those resource types are present)
