---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure DNS (public DNS) zones/records against a real Azure subscription."
---

# CATTS — Azure DNS integration tests (Terraform Testing Framework only)

Only generate if unique naming per test run is supported (zones often fixed-name, so frequently skip).

Output:

- `<terraform_root>/tests/integration-tests/dns/*.tftest.hcl`

Validate:

- Zone exists
- Record sets exist when determinable via outputs
