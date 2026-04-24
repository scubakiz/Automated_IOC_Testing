---
description: "Use when generating Python post-apply integration tests for Route Tables that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Route Table (route-table) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/route-table/`

## Runtime contract

- Load outputs via `terraform output -json`.
- Prefer `route_table_id` (or list `route_table_ids`).
- Query via `az resource show --ids <id> -o json` (Windows: `cmd.exe /c`).

## Assertions

- Route table exists
- Name/location policy checks when configured
- If outputs provide expected route names/counts, assert they exist in Azure response