---
description: "Use when generating Python post-apply integration tests for Network Interfaces (nic) that validate real Azure state."
---

# CATTS — Network Interface (nic) integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate **Azure NIC** state.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location (required)

- `<terraform_root>/tests/integration-tests/nic/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/nic/`
- `<terraform_root>/tests/integration-tests/nic/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer an output `nic_id`.
- If required outputs are missing, fail with a clear `AssertionError` listing required outputs.
- Query Azure via:
  - `az network nic show --ids <nic_id> -o json`

Windows compatibility requirement:

- Invoke Azure CLI via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions (one concern per test).

### Identity / policy

- NIC exists (`id` non-empty).
- `name` non-empty; enforce naming convention only if configured.
- `location` non-empty; enforce allowlist only if configured.
- If policy defines required tag keys: ensure tag keys exist on NIC `tags`.

### IP configurations

- `ipConfigurations` exists and has length > 0.
- At least one IP configuration is `primary` when present.
- For each IP configuration:
  - `name` non-empty
  - `subnet.id` non-empty
  - `privateIPAddressVersion` non-empty
  - `privateIPAllocationMethod` non-empty

### Optional associations (only when determinable)

- If outputs provide expected `subnet_id`: assert primary ipconfig subnet id matches.
- If outputs provide expected `public_ip_id`: assert ipconfig references that public IP.
- If outputs provide expected LB backend pool IDs: assert membership.

### Feature flags

- If Azure returns `enableAcceleratedNetworking`: assert it is boolean; if outputs provide expected: it matches.
- If Azure returns `enableIPForwarding`: assert it is boolean; if outputs provide expected: it matches.

## Minimum output contract

- Create at least one file `test_nic_basic.py` (or `test_nic_*.py`).