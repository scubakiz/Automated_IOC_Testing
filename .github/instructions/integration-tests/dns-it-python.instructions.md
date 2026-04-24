---
description: "Use when generating Python post-apply integration tests for Azure DNS (public DNS) zones/records that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Azure DNS (dns) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/dns/`

## Runtime

- Load outputs.
- Prefer `dns_zone_id` or `dns_zone_name` + `resource_group_name`.
- Query zone via `az resource show --ids <id> -o json`.
- For records, prefer outputs that provide record resource IDs; otherwise skip with a clear message.
- Windows: `cmd.exe /c az ...`.

## Assertions

- Zone exists
- Name matches expected zone name output
- Record sets exist for each output-provided record id