---
description: "Use when generating Python post-apply integration tests for Public IP Addresses (pip) that validate real Azure state."
---

# CATTS — Public IP (pip) integration tests (Python)

Generate Python integration tests that run **after** `terraform apply` and validate **Azure Public IP Address** state.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location (required)

- `<terraform_root>/tests/integration-tests/pip/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/pip/`
- `<terraform_root>/tests/integration-tests/pip/`

## Required runtime contract

Generated Python tests must:

1. Load Terraform outputs using `terraform output -json` executed in the Terraform root.
2. Identify the Public IP under test.
   - Prefer an output `public_ip_id` (or `pip_id`).
   - If an ID output is missing, accept `public_ip_name` + `resource_group_name`.
   - If required outputs are missing, fail with a clear `AssertionError` listing required outputs.
3. Query Azure via Azure CLI:
   - `az network public-ip show --ids <public_ip_id> -o json`

Windows compatibility requirement:

- Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement multiple small `test_*` functions:

- Public IP exists (query succeeds; id non-empty).
- Location is non-empty.
- If English policy defines **Allowed locations**, assert location is in allowlist.
- If English policy defines **Required tags (keys)**, assert those keys exist in tags.
- If English policy defines **Naming convention (human-readable)**, assert the Public IP name follows it.

## Feature coverage checklist (generate many tests)

When the Azure response contains these fields (or when Terraform outputs provide expected values), generate dedicated `test_*` functions for each item.

### IP addressing

- `publicIpAllocationMethod` is non-empty.
- If outputs provide expected allocation method: it matches.
- `ipAddress` presence is consistent with allocation method and provisioning state (do not hard-code exact IP unless outputs provide it).

### SKU / zones

- `sku.name` is non-empty.
- If outputs provide expected SKU: it matches.
- If Azure returns `zones`: assert it is a list; if outputs provide expected zones: it matches.

### DNS / FQDN

- If Azure returns `dnsSettings.domainNameLabel` or `dnsSettings.fqdn`: validate non-empty when outputs indicate DNS is configured.

### Timeouts / version

- If Azure returns `idleTimeoutInMinutes`: it is an integer; if outputs provide expected value: it matches.
- If Azure returns `publicIPAddressVersion`: it is non-empty.

## Minimum output contract

- Create at least one file `test_pip_basic.py` (or `test_pip_*.py`) under `<terraform_root>/tests/integration-tests/pip/`.