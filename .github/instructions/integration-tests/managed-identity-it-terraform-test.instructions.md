---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure User Assigned Managed Identity against a real Azure subscription."
---

# CATTS — Managed Identity integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Azure User Assigned Managed Identity** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope

User Assigned Managed Identities only. System-assigned identities are out of scope.

## Scope boundaries

- ONLY validate `azurerm_user_assigned_identity` (and `azurerm_role_assignment` when present).
- DO NOT add unrelated resources to "help" assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/managed-identity/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/managed-identity/`

## Strategy

If the identity is created directly in the Terraform root, assert on direct resource attributes.

If the identity is created inside modules, prefer asserting via **outputs + data sources** rather than guessing module internals.

## What to validate

Choose stable validations:

**Existence:**

- Identity exists after apply (ID is non-empty)

**Identity:**

- `name` is non-empty
- `location` is non-empty
- `client_id` is non-empty (computed — proves the identity was fully provisioned)
- `principal_id` is non-empty (computed — needed for role assignments)

**Role assignments (when present):**

- For each `azurerm_role_assignment` in scope:
  - `scope` is non-empty
  - `role_definition_id` is non-empty (Azure normalizes to ID after apply)
  - `principal_id` is non-empty

**Policy-driven (add when configured in English policy):**

- Allowed locations: `lower(location)` is in the allowlist
- Naming convention: identity name matches derived regex
- Required tags: required tag keys exist (if outputs/data provide tags)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/managed-identity/`:

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
- validates at least one identity property against Azure (directly or via data sources/outputs)
- includes at minimum the `client_id` and `principal_id` non-empty assertions
