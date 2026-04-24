---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Traffic Manager against a real Azure subscription."
---

# CATTS — Traffic Manager integration tests (Terraform Testing Framework only)

Generate only if unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/traffic-manager/*.tftest.hcl`

Validate:

- Profile exists
- Endpoint count when outputs provide expected
