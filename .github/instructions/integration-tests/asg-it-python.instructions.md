---
description: "Use when generating Python post-apply integration tests for Application Security Groups that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Application Security Group (asg) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/asg/`

Runtime:

- Prefer `asg_id` output.
- Query via `az resource show --ids <id> -o json`.

Assertions:

- ASG exists