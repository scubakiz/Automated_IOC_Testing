---
description: "Use when generating Python post-apply integration tests for Azure Front Door that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Front Door (front-door) integration tests (Python)

Use after `terraform apply`.

## Output

- `<terraform_root>/tests/integration-tests/front-door/`

## Runtime contract

- Load `terraform output -json`.
- Prefer outputs with IDs:
  - `front_door_profile_id` (AFD) or `front_door_id` (classic)
- Query Azure via `az resource show --ids <id> -o json` (via `cmd.exe /c` on Windows).

## Assertions

- Resource exists
- Policy checks (name/location/tags) only when configured.
- Feature checks when present:
  - endpoints exist
  - routes exist
  - origins/origin groups exist
  - custom domains + TLS settings exist when configured
  - WAF/security policy association exists when configured