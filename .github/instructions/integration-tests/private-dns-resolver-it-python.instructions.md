---
description: "Use when generating Python post-apply integration tests for Azure Private DNS Resolver that validate real Azure state."
---


Use together with global rules:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

# CATTS — Private DNS Resolver (private-dns-resolver) integration tests (Python)

Output:

- `<terraform_root>/tests/integration-tests/private-dns-resolver/`

Runtime:

- Prefer outputs with resolver and ruleset ids.
- Query via `az resource show --ids <id> -o json` (Windows cmd /c).

Assertions:

- resources exist