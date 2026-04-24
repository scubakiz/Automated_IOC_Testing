---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for WAF policies/configuration against a real Azure subscription."
---

# CATTS — WAF integration tests (Terraform Testing Framework only)

Only generate apply tests when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/waf/*.tftest.hcl`

Validate:

- Policy exists
- Mode/enabled when determinable
