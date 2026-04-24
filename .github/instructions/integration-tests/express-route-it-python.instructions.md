---
description: "Use when generating Python post-apply integration tests for ExpressRoute circuits that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — ExpressRoute (express-route) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/express-route/`

Runtime:

- Prefer `express_route_circuit_id` output.
- Query via `az resource show --ids <id> -o json`.

Assertions:

- circuit exists