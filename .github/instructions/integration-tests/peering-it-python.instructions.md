---
description: "Use when generating Python integration test scripts for Virtual Network Peerings that run after terraform apply and validate real Azure state."
---

# CATTS — VNet peering integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Virtual Network Peerings**.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate peering-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/peering/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/peering/`
- `<terraform_root>/tests/integration-tests/peering/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `peering_id` (best), OR
  - `peering_name` + `virtual_network_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI:

- If you have an ID: `az network vnet peering show --ids <peering_id>`
- Otherwise: `az network vnet peering show -g <rg> --vnet-name <vnet> -n <peering_name>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions (one concern per test).

### Existence / state

- Peering exists (`id` non-empty).
- `provisioningState` is a success-like state when present.
- `peeringState` is `Connected` when present.

### Flags (only when expected values are provided)

If Terraform outputs provide expected booleans, assert each matches:

- allow forwarded traffic
- allow gateway transit
- use remote gateways
- allow virtual network access

### Naming / policy

- If English policy defines a naming convention and the peering name is determinable, enforce it.

Avoid inventing org-specific peering topology requirements.

## File naming (required)

Under `<terraform_root>/tests/integration-tests/peering/`:

- `test_peering.py` (always)

## Minimum output contract

When finished, the generated Python test set must include at least one file named `test_peering*.py`.