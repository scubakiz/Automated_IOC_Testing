---
description: "Use when generating Python post-apply integration tests for Azure Load Balancers (lb) that validate real Azure state."
---

# CATTS — Load Balancer (lb) integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate **Azure Load Balancer** state.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location

- `<terraform_root>/tests/integration-tests/lb/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/lb/`
- `<terraform_root>/tests/integration-tests/lb/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer an output `lb_id`.
- Query Azure via:
  - `az network lb show --ids <lb_id> -o json`

Windows compatibility requirement:

- Invoke Azure CLI via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions.

### Identity / policy

- LB exists (`id` non-empty).
- `name` non-empty; enforce naming convention only if configured.
- `location` non-empty; enforce allowlist only if configured.
- If required tag keys configured: required tag keys exist on LB tags.

### SKU

- `sku.name` non-empty.
- If outputs provide expected SKU: it matches.

### Frontend IP configurations

- `frontendIPConfigurations` exists and has length > 0.
- For each frontend:
  - `name` non-empty
  - either `publicIPAddress.id` exists OR `subnet.id` exists
  - if private frontend: `privateIPAddress` present when static is expected

### Backend pools / rules / probes (when present)

When the Azure response includes these collections, assert they are present and non-empty when outputs indicate they are configured:

- backend address pools
- load balancing rules
- inbound NAT rules / inbound NAT pools
- probes
- outbound rules

## Minimum output contract

- Create at least one file `test_lb_basic.py` (or `test_lb_*.py`).