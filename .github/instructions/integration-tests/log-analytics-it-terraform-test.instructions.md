---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Log Analytics Workspace against a real Azure subscription."
---

# CATTS — Log Analytics Workspace integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Azure Log Analytics Workspace** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate Log Analytics Workspace-related resources (`azurerm_log_analytics_workspace` and related sub-resources).
- DO NOT add unrelated resources to "help" assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/log-analytics/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/log-analytics/`

## Strategy

If the workspace is created directly in the Terraform root, assert on direct resource attributes.

If the workspace is created inside modules, prefer asserting via **outputs + data sources** rather than guessing module internals.

## What to validate

Choose stable validations:

**Existence:**

- Workspace exists after apply (ID is non-empty)

**Identity:**

- `name` is non-empty
- `location` is non-empty

**Configuration:**

- `sku` is non-empty
- `retention_in_days` >= 30

**Policy-driven (add when configured in English policy):**

- Allowed locations: `lower(location)` is in the allowlist
- Naming convention: workspace name matches derived regex
- Required tags: required tag keys exist (if outputs/data provide tags)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/log-analytics/`:

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
- validates at least one workspace property against Azure (directly or via data sources/outputs)
- includes at minimum the SKU and retention assertions
