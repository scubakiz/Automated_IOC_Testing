---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Private DNS Zones against a real Azure subscription."
---

# CATTS — Private DNS Zone integration tests (Terraform Testing Framework only)

Private DNS zone names are usually fixed; only generate apply tests when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/private-dns-zone/*.tftest.hcl`

Validate:

- Zone exists
- Link exists when determinable
