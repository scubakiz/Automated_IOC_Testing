---
description: "Use when generating Python integration test scripts for Subnets that run after terraform apply and validate real Azure state."
---

# CATTS — Subnet integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Subnets**.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate subnet-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/subnet/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/subnet/`
- `<terraform_root>/tests/integration-tests/subnet/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `subnet_id` (best), OR
  - `subnet_name` + `virtual_network_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI:

- `az network vnet subnet show --ids <subnet_id>` OR `-g/-n/--vnet-name`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions (one concern per test).

### Existence / identity

- Subnet exists (Azure query succeeds; `id` non-empty).
- Subnet `name` is non-empty.

### Addressing

- Address prefixes exist and are non-empty.
- If outputs provide expected CIDR(s) (e.g., `subnet_cidr`, `subnet_prefixes`, `address_prefixes`), assert the Azure response matches exactly.

### Network policy flags (when present)

If the Azure response includes these fields, assert they are present and in expected states when outputs provide expected values:

- private endpoint network policies
- private link service network policies

### Associations (when determinable)

- If outputs provide `nsg_id`, assert subnet has `networkSecurityGroup.id` and it matches.
- If outputs provide `route_table_id`, assert subnet has a route table id and it matches.

### Delegations (when configured)

- If outputs provide expected delegation service names, assert each expected service is present.

### Service endpoints (when configured)

- If outputs provide `expected_service_endpoints` (list), assert each expected service endpoint exists in the Azure response.

Policy note:

- Subnets do not have their own `location` or `tags` in the subnet response; do not attempt to enforce those policies here unless you can deterministically tie them to the parent VNet (via outputs + additional Azure query).

## File naming (required)

Under `<terraform_root>/tests/integration-tests/subnet/`:

- `test_subnet_basic.py` (always)

## Minimum output contract

When finished, the generated Python test set must include at least one file named `test_subnet_*.py`.