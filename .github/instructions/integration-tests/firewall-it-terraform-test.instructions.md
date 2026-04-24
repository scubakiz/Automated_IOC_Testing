---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Firewall against a real Azure subscription."
---

# CATTS — Azure Firewall integration tests (Terraform Testing Framework only)

Generate Terraform-native integration tests for Azure Firewall using `terraform test` with `command = apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Important limitation (state isolation)

- Only generate `command = apply` tests when unique naming per test run is supported.
- Otherwise, skip Terraform integration tests and generate Python post-apply validation.

## Output location

- `<terraform_root>/tests/integration-tests/firewall/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/firewall/`

## Test authoring guidance

- Use a single `run "apply" { command = apply }`.
- Assert via `data` sources / outputs when possible.
- Every `assert` needs a specific `error_message`.

## Minimum output contract

If generated, include at least one `.tftest.hcl` under `<terraform_root>/tests/integration-tests/firewall/`.
