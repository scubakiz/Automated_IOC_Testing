---
description: "Use when generating Python post-apply integration tests for Azure Bastion that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Bastion (bastion) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/bastion/`

Runtime:

- Prefer `bastion_id` output.
- Query via `az resource show --ids <id> -o json` (Windows cmd /c).

Assertions:

- Bastion exists
- policy checks when configured
- IP configuration exists