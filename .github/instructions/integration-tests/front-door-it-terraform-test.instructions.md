---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Front Door against a real Azure subscription."
---

# CATTS — Front Door integration tests (Terraform Testing Framework only)

Because apply tests run in isolated state, only generate when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/front-door/*.tftest.hcl`

Validate stable invariants via outputs/data sources:

- Profile/frontdoor exists
- Endpoints/routes/origins exist when outputs provide identifiers
