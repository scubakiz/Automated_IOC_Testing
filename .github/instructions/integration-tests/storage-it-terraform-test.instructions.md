---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Storage Accounts against a real Azure subscription."
---

# CATTS — Storage Account integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate integration tests for **Azure Storage Accounts** using only the Terraform Testing Framework (`terraform test`).

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`
- Assertions validate real Azure state (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate Storage Account-related resources (`azurerm_storage_account` and related sub-resources).
- DO NOT add unrelated resources to "help" assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/storage/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/storage/`

## Strategy

If the Storage Account is created directly in the Terraform root, assert on direct resource attributes.

If the Storage Account is created inside modules, prefer asserting via **outputs + data sources** rather than guessing module internals.

## What to validate

Choose stable validations:

**Existence:**

- Storage Account exists after apply (ID is non-empty)

**Identity:**

- `name` is non-empty
- `location` is non-empty

**Security configuration (required — these are security posture checks):**

- `min_tls_version` is `"TLS1_2"`
- `https_traffic_only_enabled` is `true`
- `public_network_access_enabled` is `false`
- `allow_nested_items_to_be_public` is `false`

**Account properties:**

- `account_tier` is non-empty
- `account_replication_type` is non-empty

**Policy-driven (add when configured in English policy):**

- Allowed locations: `lower(location)` is in the allowlist
- Required tags: required tag keys exist (if outputs/data provide tags)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/storage/`:

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
- validates at least one Storage Account security property against Azure (directly or via data sources/outputs)
- includes at minimum the TLS version and public access assertions
