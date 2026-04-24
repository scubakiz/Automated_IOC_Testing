---
description: "Use when generating Python post-apply integration tests for Azure Route Server that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Route Server (route-server) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/route-server/`

Runtime:

- Prefer `route_server_id` output.
- Query via `az resource show --ids <id> -o json`.

Assertions:

- route server exists