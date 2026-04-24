---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Public IP Addresses (pip) against a real Azure subscription."
---

# CATTS — Public IP (pip) integration tests (Terraform Testing Framework only)

Generate Terraform-native integration tests for Public IP resources using `terraform test` with `command = apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Important limitation (state isolation)

Terraform test applies in an **isolated test state**.

- If the Terraform root deploys to fixed names/resource groups, `command = apply` tests can fail with “already exists”.

Generator behavior (required):

- Only generate `command = apply` tests when the Terraform root can deploy uniquely per test run (e.g., `test_run_id`, `suffix`, or similar).
- If you cannot make names unique without guessing, skip Terraform integration tests and generate only Python post-apply validation.

## Output location (required)

- `<terraform_root>/tests/integration-tests/pip/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/pip/`

## Test authoring guidance

- Use a single `run "apply" { command = apply }`.
- Prefer asserts based on IDs/names from outputs or `data` sources.
- Keep each `assert` actionable with a specific `error_message`.

## Minimum output contract

If generated, include at least one `.tftest.hcl` under `<terraform_root>/tests/integration-tests/pip/` with a `command = apply` run.
