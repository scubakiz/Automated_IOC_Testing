---
description: "Use when generating Python post-apply integration tests for Azure Firewall that validate real Azure state."
---

# CATTS — Azure Firewall integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate **Azure Firewall** state.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location

- `<terraform_root>/tests/integration-tests/firewall/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/firewall/`
- `<terraform_root>/tests/integration-tests/firewall/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer an output `firewall_id`.
- Query Azure via:
  - `az network firewall show --ids <firewall_id> -o json`

Windows compatibility requirement:

- Invoke Azure CLI via `cmd.exe /c az ...`.

## Assertions to implement

Prefer many small `test_*` functions.

### Identity / policy

- Firewall exists (`id` non-empty).
- `name` non-empty; enforce naming convention only if configured.
- `location` non-empty; enforce allowlist only if configured.
- If required tag keys configured: required tag keys exist on firewall tags.

### SKU / tier / threat intel

- If Azure returns `sku.name` / `sku.tier`: validate non-empty; if outputs provide expected: assert match.
- If Azure returns threat intel mode: validate it is non-empty; if outputs provide expected: assert match.

### IP configurations

- `ipConfigurations` exists and has length > 0 (when the Terraform config suggests the firewall is deployed).
- For each ip config:
  - `name` non-empty
  - `subnet.id` non-empty
  - `publicIPAddress.id` non-empty (when expected)

### Management IP configuration (when present)

- If Azure returns management IP config: assert its subnet/public IP IDs are non-empty.

### Firewall policy linkage (when present)

- If Azure returns `firewallPolicy.id` and outputs provide expected policy id: assert match.

## Minimum output contract

- Create at least one file `test_firewall_basic.py` (or `test_firewall_*.py`).