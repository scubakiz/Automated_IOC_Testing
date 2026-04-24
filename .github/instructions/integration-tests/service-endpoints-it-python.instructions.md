---
description: "Use when generating Python post-apply integration tests for subnet Service Endpoints (service-endpoints) that validate real Azure state."
---

# CATTS — Service Endpoints integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate service endpoints configured on subnets.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location

- `<terraform_root>/tests/integration-tests/service-endpoints/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/service-endpoints/`
- `<terraform_root>/tests/integration-tests/service-endpoints/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs:
  - `subnet_id` (single) OR `subnet_ids` (list)
  - optionally `expected_service_endpoints` (list of strings)
- Query Azure via:
  - `az network vnet subnet show --ids <subnet_id> -o json`

Windows compatibility requirement:

- Invoke Azure CLI via `cmd.exe /c az ...`.

## Assertions to implement

- Subnet exists (id non-empty).
- If allowed locations configured and subnet has location available in response: enforce allowlist.
- Assert subnet has at least one service endpoint configured (Azure response contains `serviceEndpoints` list with length > 0).
- If `expected_service_endpoints` output exists: assert each expected service appears in Azure response.

## Feature coverage checklist

Generate dedicated tests for:

- Subnet exists and id non-empty.
- `serviceEndpoints` exists and length > 0 when service endpoints are expected.
- For each service endpoint entry:
  - `service` is non-empty
  - `provisioningState` is non-empty
- If outputs provide expected services: exact set match (order-insensitive).

Avoid enforcing non-deterministic, subscription-specific defaults.

## Minimum output contract

- Create at least one file `test_service_endpoints_basic.py` (or `test_service_endpoints_*.py`).