---
description: "Use when generating Python post-apply integration tests for Azure Traffic Manager that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Traffic Manager (traffic-manager) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/traffic-manager/`

## Runtime

- Load `terraform output -json`.
- Prefer outputs: `traffic_manager_profile_id` OR `traffic_manager_profile_name` + `resource_group_name`.
- Query via `az resource show --ids <id> -o json` using `cmd.exe /c`.

## Assertions

- Profile exists
- Location/tags/name policy checks when configured
- DNS config present
- Monitor config present
- Endpoints present when outputs provide expected endpoint ids/names