---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Route Tables against a real Azure subscription."
---

# CATTS — Route Table integration tests (Terraform Testing Framework only)

Generate apply tests only when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/route-table/*.tftest.hcl`

Validate:

- route table exists (id non-empty)
- route count when determinable via outputs/data
