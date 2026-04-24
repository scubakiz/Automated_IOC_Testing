---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for NAT Gateway (azurerm_nat_gateway and associations) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — NAT Gateway (nat-gateway) unit test generation (Terraform-only)

## Scope

- `azurerm_nat_gateway`
- `azurerm_nat_gateway_public_ip_association`
- `azurerm_nat_gateway_public_ip_prefix_association`
- `azurerm_subnet_nat_gateway_association`

## Output

- `<terraform_root>/tests/unit-tests/nat-gateway/*.tftest.hcl`

## Feature checklist

For each `azurerm_nat_gateway.<NAME>`:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if configured
- If `sku_name` exists: non-empty
- If `idle_timeout_in_minutes` exists: integer > 0
- If `zones` exists: list length > 0

For each association resource:

- required IDs are non-empty
- subnet association has both subnet_id and nat_gateway_id non-empty
