---
description: "Use when generating Terraform Testing Framework integration tests (.tftest.hcl) for Azure Application Gateway against a real Azure subscription."
---

# CATTS — Application Gateway integration tests (Terraform Testing Framework only)

Use `terraform test` with `command = apply` only when the root can deploy uniquely per test run.

If unique naming cannot be guaranteed without guessing, skip Terraform integration tests and generate Python post-apply tests instead.

Output:

- `<terraform_root>/tests/integration-tests/app-gateway/*.tftest.hcl`

Validate (when determinable):

- Gateway exists (ID non-empty)
- WAF enabled/mode when configured
- Listener/rule counts when outputs provide expected values
