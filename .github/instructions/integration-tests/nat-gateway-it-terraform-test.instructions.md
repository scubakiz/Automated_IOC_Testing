---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for NAT Gateway against a real Azure subscription."
---

# CATTS — NAT Gateway integration tests (Terraform Testing Framework only)

Only generate apply tests when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/nat-gateway/*.tftest.hcl`

Validate:

- NAT gateway exists after apply
