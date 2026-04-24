---
description: "Use when generating integration tests for API Management (APIM) using Terraform's native testing framework (terraform test, .tftest.hcl) against a real Azure subscription."
---

# CATTS — APIM integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate **integration tests** for **APIM** using **only** the Terraform Testing Framework (`terraform test`).

These resource-specific instructions are designed to be used together with the global policies in:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that authenticate to Azure and perform `command = apply`

## Scope boundaries

- ONLY validate APIM-related resources and APIM ↔ VNet/Subnet/NSG integration.
- DO NOT add unrelated resources to “help” assertions.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/apim/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/apim/`

## Important limitation (state isolation)

Terraform test runs apply in an **isolated test state**.

- If the Terraform root under test deploys to a _fixed_ resource group/name that may already exist, `command = apply` tests can fail with "already exists".

Generator behavior (required):

- Only generate Terraform `command = apply` tests when the Terraform root can deploy uniquely per test run.
  - Signal: a variable like `test_run_id`, `suffix`, or similar that can be used to make resource group and/or APIM names unique.
- If you cannot make names unique **without guessing**, skip Terraform integration tests for APIM and generate only Python post-apply validation instead.

## Test authoring guidance (tftest.hcl)

- Use a single `run "apply" { command = apply }`.
- Put multiple small asserts (each with a specific `error_message`) under that run.
- Use only values you can observe from configuration after apply (resource ids, names, locations).

## Minimum output contract

If generated, the APIM Terraform integration test set must include at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/integration-tests/apim/`

with at least one `run` block using `command = apply`.
