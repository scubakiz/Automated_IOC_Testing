---
description: "Use when generating Python integration test scripts for Virtual Networks that run after terraform apply and validate real Azure state (vnet/subnet/peering)."
---

# CATTS — VNet integration tests (Python)

These instructions define how an agent should generate **Python-based integration tests** for VNets.

These resource-specific instructions are designed to be used together with the global policies in:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run **after** `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate VNet-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs, not from naming heuristics.

## Output location (required)

Given a Terraform root folder, write Python tests to:

- `<terraform_root>/tests/integration-tests/vnet/`

Before creating files, ensure these folders exist (create if missing):

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/vnet/`
- `<terraform_root>/tests/integration-tests/vnet/`

## Required runtime contract

Generated Python tests must:

1. Locate Terraform outputs

- Execute `terraform output -json` in the Terraform root working directory, OR
- Read a previously-saved `terraform-output.json` artifact created by CI.

2. Identify the VNet(s) under test

- Prefer using outputs containing:
  - `vnet_id` (best)
  - `vnet_name` and `resource_group_name` (acceptable)
  - `subnet_ids` / `subnet_names`

If required outputs are missing, the script should fail with a clear error explaining which outputs are required.

3. Query Azure
   Use one of these approaches (pick one and be consistent):

- **Azure CLI (lowest dependency)**
  - Call `az network vnet show` and `az network vnet subnet show` with `--ids` or `-g/-n`.
  - Parse JSON.
  - Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

- **Azure SDK for Python (preferred when dependencies are allowed)**
  - `azure-identity` for auth
  - `azure-mgmt-network` for VNets/Subnets/Peerings

Do not mix both in one script.

## Assertions to implement

Implement validations that are stable across environments.

### VNet assertions

- VNet exists
- Location is non-empty
- If the English policy defines **Allowed locations**, assert the VNet location is in that allowlist
- Address space(s) match expected (if provided)
- If the English policy defines **Required tags (keys)**, assert those tag keys exist
- If the English policy defines a **Naming convention (human-readable)**, assert the VNet name follows it

Policy behavior (required):

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

### Subnet assertions

- Each expected subnet exists
- Each subnet has expected CIDR prefix(es)
- Network policy flags match expected (if provided)

### Peering assertions (if present)

- Peering exists and is connected
- Peering flags match expected policy

## Script interface (recommendation)

Generated scripts should accept configuration via:

- environment variables (for subscription/tenant if needed)
- Terraform outputs (for IDs/names)

They should exit non-zero on failure.

## Logging & diagnostics

- Print the VNet ID(s) being validated.
- On failure, print the observed value and the expected value.

## Minimum output contract

When finished, the generated Python test set must include:

- at least one Python file under `<terraform_root>/tests/integration-tests/vnet/` named like `test_vnet_*.py`
- a clear “how to run” note at the top (expects to be run from the Terraform root)