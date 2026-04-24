---
description: "Use when generating Python post-apply integration tests for Azure Application Gateway that validate real Azure state."
---

# CATTS — Application Gateway (app-gateway) integration tests (Python)

Generate Python tests that run **after** `terraform apply` and validate Application Gateway in Azure.

Use with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

## Output location

- `<terraform_root>/tests/integration-tests/app-gateway/`

## Required runtime contract

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs: `app_gateway_id` (best) OR `app_gateway_name` + `resource_group_name`.
- Query Azure using Azure CLI.
  - Prefer a resource-id query to avoid CLI surface differences: `az resource show --ids <id> -o json`.
- Windows: invoke via `cmd.exe /c az ...`.

## Assertions (generate many small tests)

- Gateway exists; id non-empty.
- Location non-empty; enforce allowlist only if configured.
- If policy defines required tags: assert required keys exist.
- If policy defines naming convention: assert name matches.

Type-specific (when present in response and/or expected via outputs):

- SKU name/tier non-empty.
- Frontend IP configurations exist.
- Listeners exist.
- Backend pools exist.
- Routing rules exist.
- WAF enabled/mode when configured.