---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for ExpressRoute circuits/peerings/authorizations from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — ExpressRoute (express-route) unit test generation (Terraform-only)

## Scope

- `azurerm_express_route_circuit`
- `azurerm_express_route_circuit_peering`
- `azurerm_express_route_circuit_authorization`

## Output

- `<terraform_root>/tests/unit-tests/express-route/*.tftest.hcl`

## Feature checklist

Circuit:

- name non-empty; naming regex only if policy configured
- RG/location non-empty; allowed locations only if configured
- service_provider_name non-empty
- peering_location non-empty
- bandwidth_in_mbps integer > 0
- sku tier/family non-empty

Peering:

- peering_type non-empty
- peer_asn integer when present
- primary/secondary peer address prefixes non-empty
- vlan_id integer when present

Authorization:

- name non-empty
- circuit_name non-empty
