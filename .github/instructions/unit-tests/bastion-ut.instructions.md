---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Bastion (azurerm_bastion_host) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Bastion (bastion) unit test generation (Terraform-only)

## Scope

- `azurerm_bastion_host`

## Output

- `<terraform_root>/tests/unit-tests/bastion/*.tftest.hcl`

## Feature checklist

For each `azurerm_bastion_host.<NAME>`:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if configured
- `sku` non-empty when present
- `ip_configuration` exists and length > 0
  - ip config name non-empty
  - subnet_id non-empty
  - public_ip_address_id non-empty
- If feature flags exist: validate booleans and non-empty values (tunneling, copy/paste, file copy)
