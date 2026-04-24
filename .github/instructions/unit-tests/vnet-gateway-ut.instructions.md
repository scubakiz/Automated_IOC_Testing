---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Virtual Network Gateways and connections from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — VNet Gateway (vnet-gateway) unit test generation (Terraform-only)

## Scope

- `azurerm_virtual_network_gateway`
- `azurerm_local_network_gateway`
- `azurerm_virtual_network_gateway_connection`

## Output

- `<terraform_root>/tests/unit-tests/vnet-gateway/*.tftest.hcl`

## Feature checklist

VNet gateway:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if configured
- `type` non-empty (Vpn/ExpressRoute)
- `vpn_type` non-empty when present
- `sku` non-empty
- `ip_configuration` exists with subnet_id/public_ip_address_id non-empty
- `enable_bgp` boolean when present
- `active_active` boolean when present

Local network gateway:

- name non-empty
- gateway_address non-empty OR address_space list non-empty

Connection:

- name non-empty
- type non-empty
- `virtual_network_gateway_id` non-empty
- local/peer gateway id non-empty when present
- shared_key non-empty when present
