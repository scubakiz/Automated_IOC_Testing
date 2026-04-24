---
description: "Use when generating integration tests for Subnets using Terraform's native testing framework (terraform test, .tftest.hcl) against a real Azure subscription."
---

# CATTS — Subnet integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Subnets** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate subnet-related resources (`azurerm_subnet`).
- DO NOT add unrelated resources to “help” assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/subnet/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/subnet/`

## Strategy

Prefer asserting via **outputs + data sources** if the subnet is created inside modules.

If the subnet is created directly in the root, you may assert on direct resources.

## What to validate

Choose stable validations:

- Subnet exists after apply (ID is non-empty)
- Address prefixes are non-empty
- Network policy flags match expected values (only if your config sets them)

Add these subnet feature validations when determinable via outputs and/or `data` sources:

- Service endpoints: if configured in Terraform, validate Azure reports the expected service endpoints on the subnet.
- Delegations: if configured in Terraform, validate Azure reports the expected delegation service names.
- NSG association: if Terraform outputs provide expected `nsg_id`, validate subnet has NSG and matches.
- Route table association: if Terraform outputs provide expected `route_table_id`, validate match.

Policy note:

- Subnets do not have independent tags; tag policy belongs on taggable parent resources.

## File naming (required)

Under `<terraform_root>/tests/integration-tests/subnet/`:

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
- validates at least one subnet-related property against Azure (directly or via data sources/outputs)
