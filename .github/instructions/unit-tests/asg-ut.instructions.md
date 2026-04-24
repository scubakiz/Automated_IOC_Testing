---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Application Security Groups (azurerm_application_security_group) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Application Security Group (asg) unit test generation (Terraform-only)

## Scope

- `azurerm_application_security_group`

## Output

- `<terraform_root>/tests/unit-tests/asg/*.tftest.hcl`

## Feature checklist

For each `azurerm_application_security_group.<NAME>`:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if configured
