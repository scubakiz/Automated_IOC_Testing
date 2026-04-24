---
description: "Use when generating Python post-apply integration tests for Virtual Network Gateways that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — VNet Gateway (vnet-gateway) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/vnet-gateway/`

Runtime:

- Prefer `virtual_network_gateway_id` output.
- Query via `az resource show --ids <id> -o json` (Windows cmd /c).

Assertions:

- gateway exists