---
description: "Use when generating Python post-apply integration tests for Azure DDoS Protection Plan that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — DDoS Protection (ddos) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/ddos/`

## Runtime

- Load outputs; prefer `ddos_plan_id`.
- Query via `az resource show --ids <id> -o json` (Windows: `cmd.exe /c`).

## Assertions

- Plan exists
- Name/location/tags policy checks when configured
- If outputs provide associated VNet id(s), assert each VNet has ddos plan enabled (may require additional resource queries)