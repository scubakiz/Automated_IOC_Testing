---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Key Vault against a real Azure subscription."
---

# CATTS — Key Vault integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Azure Key Vault** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate Key Vault-related resources (`azurerm_key_vault` and related sub-resources).
- DO NOT add unrelated resources to "help" assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/key-vault/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/key-vault/`

## Strategy

If the Key Vault is created directly in the Terraform root, assert on direct resource attributes.

If the Key Vault is created inside modules, prefer asserting via **outputs + data sources** rather than guessing module internals.

## What to validate

Choose stable validations:

**Existence:**

- Key Vault exists after apply (ID is non-empty)

**Identity:**

- `name` is non-empty
- `location` is non-empty

**Security configuration (required — these are security posture checks):**

- `sku_name` is non-empty
- `purge_protection_enabled` is `true`
- `soft_delete_retention_days` is >= 7
- `public_network_access_enabled` is `false` OR `network_acls[0].default_action == "Deny"`

**Policy-driven (add when configured in English policy):**

- Allowed locations: `lower(location)` is in the allowlist
- Naming convention: Key Vault name matches derived regex
- Required tags: required tag keys exist (if outputs/data provide tags)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/key-vault/`:

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
- validates at least one Key Vault property against Azure (directly or via data sources/outputs)
- includes at minimum the purge protection and network access assertions
