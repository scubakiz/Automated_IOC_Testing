---
description: "Use when generating Python post-apply integration tests for Web Application Firewall (WAF) policies/configuration that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — WAF (waf) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/waf/`

## Runtime

- Load `terraform output -json`.
- Prefer outputs: `waf_policy_id` (or list) and/or `app_gateway_id` for embedded WAF config.
- Query using `az resource show --ids <id> -o json` (Windows: `cmd.exe /c`).

## Assertions

- Policy/config exists
- Mode/enabled flags present when configured
- Managed rule sets present when configured
- Custom rules present when configured
- Policy association to Front Door/App Gateway when outputs provide expected linkage