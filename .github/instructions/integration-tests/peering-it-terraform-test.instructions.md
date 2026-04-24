---
description: "Use when generating integration tests for Virtual Network Peerings using Terraform's native testing framework (terraform test, .tftest.hcl) against a real Azure subscription."
---

# CATTS — VNet peering integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Virtual Network Peerings** using only Terraform's test framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Scope boundaries

- ONLY validate peering-related resources (`azurerm_virtual_network_peering`).
- DO NOT add unrelated resources to “help” assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/peering/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/peering/`

## What to validate

- Peering exists after apply (ID is non-empty)
- Policy flags match expected values (if your config sets them)

Add these peering feature validations when determinable:

- Provisioning state indicates success (via `data` source or output if available).
- Peering connectivity state is connected (when surfaced by the chosen data source / provider).

Avoid inventing topology requirements.

## File naming (required)

Under `<terraform_root>/tests/integration-tests/peering/`:

- `apply_and_validate.tftest.hcl` (always)

## Diagnostics requirement (must follow)

- Keep a single `run "apply" { command = apply }` to avoid redeploying per-check.
- Every `assert` MUST have a specific `error_message` that identifies the failing resource and property.
- Prefer multiple small asserts (each with its own message) over one compound boolean.
- CI visibility recommendation: use JUnit output:
  - `terraform test -junit-xml=tests/test-results.xml`

## Minimum output contract

When finished, include at least one `.tftest.hcl` file that:

- contains a `run` block with `command = apply`
- validates at least one peering-related property against Azure (directly or via data sources/outputs)
