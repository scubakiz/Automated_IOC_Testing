---
description: "Use when generating Python post-apply integration tests for Private Endpoints that validate real Azure state."
---

# CATTS — Private Endpoint integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate **Azure Private Endpoint** state.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location

- `<terraform_root>/tests/integration-tests/private-endpoint/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/private-endpoint/`
- `<terraform_root>/tests/integration-tests/private-endpoint/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer an output `private_endpoint_id`.
- Query Azure via:
  - `az network private-endpoint show --ids <private_endpoint_id> -o json`

Windows compatibility requirement:

- Invoke Azure CLI via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions.

### Identity / policy

- Private endpoint exists (`id` non-empty).
- `name` non-empty; enforce naming convention only if configured.
- `location` non-empty; enforce allowlist only if configured.
- If required tag keys configured: required tag keys exist on tags.

### Subnet placement

- `subnet.id` is non-empty.
- If outputs provide expected `subnet_id`: assert match.

### Connections

- At least one connection exists (manual or automatic):
  - `privateLinkServiceConnections` and/or `manualPrivateLinkServiceConnections` non-empty.
- If outputs provide expected `group_ids` / `subresource_names`: assert they match.
- If outputs provide expected target resource id: assert connection target matches.

### Network interfaces / private IPs

- If Azure returns `networkInterfaces`: it is non-empty.
- If Azure returns private IP addresses, validate presence/shape (do not hard-code specific IP unless outputs provide it).

### Private DNS zone groups (when used)

- If outputs provide expected private DNS zone ids, query zone groups (if generator chooses) or assert the private endpoint has DNS configuration consistent with them.

## Minimum output contract

- Create at least one file `test_private_endpoint_basic.py` (or `test_private_endpoint_*.py`).