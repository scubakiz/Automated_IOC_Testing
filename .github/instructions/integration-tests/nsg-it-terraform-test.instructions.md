---
description: "Use when generating integration tests for Network Security Groups using Terraform's native testing framework (terraform test, .tftest.hcl) against a real Azure subscription."
---

# CATTS — NSG integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Network Security Groups** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate NSG-related resources (`azurerm_network_security_group`).
- DO NOT add unrelated resources to “help” assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/nsg/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/nsg/`

## Strategy

If the NSG is created directly in the Terraform root, you may assert on direct resources.

If the NSG is created inside modules, prefer asserting via **outputs + data sources** rather than guessing.

## What to validate

Choose stable validations:

- NSG exists after apply (ID is non-empty)
- NSG location is non-empty
- Optional: if rules are managed in the same configuration, assert at least one rule exists (avoid hard-coded org policy)

Add these policy-driven validations when configured in the English policy and values are determinable in test context:

- Allowed locations: `lower(location)` is in allowlist
- Naming convention: NSG name matches derived regex

Add these feature validations when determinable:

- Tags: if English policy defines **Required tags (keys)** and tags are available via outputs/data, assert required tag keys exist
- Rule shape: validate rules collection exists; do not hard-code specific rule names/ports unless provided by Terraform outputs

## File naming (required)

Under `<terraform_root>/tests/integration-tests/nsg/`:

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
- validates at least one NSG-related property against Azure (directly or via data sources/outputs)
