---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure DDoS Protection Plan against a real Azure subscription."
---

# CATTS — DDoS Protection integration tests (Terraform Testing Framework only)

Generate only when unique naming per test run is supported.

Output:

- `<terraform_root>/tests/integration-tests/ddos/*.tftest.hcl`

Validate:

- Plan exists after apply
- VNet association when determinable
