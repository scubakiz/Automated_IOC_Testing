---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Route Server (azurerm_route_server) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Route Server (route-server) unit test generation (Terraform-only)

## Scope

- `azurerm_route_server`

## Output

- `<terraform_root>/tests/unit-tests/route-server/*.tftest.hcl`

## Feature checklist

For each `azurerm_route_server.<NAME>`:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if policy configured
- subnet_id non-empty
- branch_to_branch_traffic_enabled boolean when present
