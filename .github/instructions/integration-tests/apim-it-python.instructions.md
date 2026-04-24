---
description: "Use when generating Python integration test scripts for API Management (APIM) that run after terraform apply and validate real Azure state, including VNet+NSG integration."
---

# CATTS — APIM integration tests (Python)

These instructions define how an agent should generate **Python-based integration tests** for **Azure API Management (APIM)**.

These resource-specific instructions are designed to be used together with the global policies in:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run **after** `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate APIM and the APIM ↔ VNet/Subnet/NSG integration points.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Given a Terraform root folder, write Python tests to:

- `<terraform_root>/tests/integration-tests/apim/`

Before creating files, ensure these folders exist (create if missing):

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/apim/`
- `<terraform_root>/tests/integration-tests/apim/`

## Required runtime contract

Generated Python tests must:

1. Locate Terraform outputs

- Execute `terraform output -json` in the Terraform root working directory, OR
- Read a previously-saved `terraform-output.json` artifact created by CI.

2. Identify the APIM under test

Prefer, in order:

- an output named `apim_name` (best)
- parse `terraform.tfvars` for `apim_name = "..."` (acceptable fallback)
- list APIM services in the resource group and select only when unambiguous (last resort)

If APIM name cannot be determined unambiguously, fail with a clear `AssertionError` explaining what outputs/inputs are required.

3. Query Azure

Use Azure CLI (lowest dependency):

- `az apim show -g <rg> -n <name> -o json`
- `az network vnet subnet show --ids <subnet_id> -o json`

Windows compatibility requirement:

- If `az` resolves to `az.cmd`, invoke it via `cmd.exe /c az ...`.

## Assertions to implement (dozens encouraged)

Prefer many small `test_*` functions (one concern per test). Tests should be stable across environments.

### APIM existence and identity

- APIM exists (query succeeds; id non-empty)
- Location is non-empty
- If English policy defines **Allowed locations**, APIM location must be in allowlist

### APIM networking (VNet + Subnet)

- APIM virtual network type is `Internal` when configured that way in Terraform
- APIM has a subnet configured (subnetResourceId is non-empty)
- If Terraform outputs provide `subnet_id`, APIM subnetResourceId matches it

### NSG integration via subnet

- Query subnet by `subnet_id` and assert it has `networkSecurityGroup.id` present
- (Optional) if you can also determine expected NSG name/id reliably (via outputs or unambiguous lookup), assert the subnet’s NSG id matches expected.

### Tag policy (if configured)

- If English policy defines **Required tags (keys)**, assert those keys exist on the APIM resource tags.

### Naming policy (if configured)

- If English policy defines a **Naming convention (human-readable)**, validate APIM name follows it.
  - Translate tokens into a regex as CATTS does elsewhere.
  - Constrain `<region>` to the allowed locations list when configured.

## Minimum output contract

When finished, the generated Python test set must include:

- at least one Python file under `<terraform_root>/tests/integration-tests/apim/` named like `test_apim_*.py`
- a clear “how to run” note at the top (expects to be run from the Terraform root)