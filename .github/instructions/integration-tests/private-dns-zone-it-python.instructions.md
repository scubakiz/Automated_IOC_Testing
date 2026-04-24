---
description: "Use when generating Python post-apply integration tests for Azure Private DNS Zones, links, and records that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Private DNS Zone (private-dns-zone) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/private-dns-zone/`

## Runtime

- Load outputs.
- Prefer `private_dns_zone_id`.
- Query via `az resource show --ids <id> -o json` (Windows: `cmd.exe /c`).
- For links/records, prefer outputs that provide IDs.

## Assertions

- Zone exists
- VNet links exist when outputs provide expected link ids
- Records exist when outputs provide record ids