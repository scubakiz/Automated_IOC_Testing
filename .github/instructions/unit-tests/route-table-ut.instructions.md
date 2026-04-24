---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Route Tables (azurerm_route_table/azurerm_route) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Route Table (route-table) unit test generation (Terraform-only)

Use together with:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Scope

- `azurerm_route_table`
- `azurerm_route`
- `azurerm_subnet_route_table_association` (when present)

## Output

- `<terraform_root>/tests/unit-tests/route-table/*.tftest.hcl`

## Feature coverage checklist

For each `azurerm_route_table.<NAME>`:

- name non-empty; naming regex only if policy configured.
- RG/location non-empty; allowed locations only if policy configured.
- If `disable_bgp_route_propagation` exists: boolean.
- If `tags` exist and are literal: allow checks only when policy provides required tag keys.

For each `azurerm_route.<NAME>`:

- `name` non-empty
- `resource_group_name` non-empty
- `route_table_name` non-empty
- `address_prefix` non-empty
- `next_hop_type` non-empty
- If `next_hop_in_ip_address` exists: non-empty

For each `azurerm_subnet_route_table_association.<NAME>`:

- `subnet_id` non-empty
- `route_table_id` non-empty
