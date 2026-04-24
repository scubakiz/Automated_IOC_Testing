---
description: "Use when generating Python post-apply integration tests for NAT Gateway that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — NAT Gateway (nat-gateway) integration tests (Python)

## Output

- `<terraform_root>/tests/integration-tests/nat-gateway/`

## Runtime

- outputs: `nat_gateway_id` (or list)
- query: `az resource show --ids <id> -o json` (Windows: cmd /c)

## Assertions

- NAT gateway exists
- name/location/tag/naming policy checks when configured
- if outputs provide expected subnet ids: assert association exists (may require querying subnet)