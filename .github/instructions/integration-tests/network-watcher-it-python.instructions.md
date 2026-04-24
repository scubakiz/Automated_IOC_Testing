---
description: "Use when generating Python post-apply integration tests for Network Watcher/flow logs that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Network Watcher (network-watcher) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/network-watcher/`

Runtime:

- Prefer outputs for flow log ids.
- Query via `az resource show --ids <id> -o json` (Windows cmd /c).

Assertions:

- resources exist