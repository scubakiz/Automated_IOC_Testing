---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Private DNS Zones, links, and records from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Private DNS Zone (private-dns-zone) unit test generation (Terraform-only)


## Scope

- Zones: `azurerm_private_dns_zone`
- Links: `azurerm_private_dns_zone_virtual_network_link`
- Record sets: `azurerm_private_dns_*_record`

## Output

- `<terraform_root>/tests/unit-tests/private-dns-zone/*.tftest.hcl`

## Feature checklist

For each `azurerm_private_dns_zone.<NAME>`:

- name non-empty
- RG non-empty

For each `azurerm_private_dns_zone_virtual_network_link.<NAME>`:

- name non-empty
- `private_dns_zone_name` non-empty
- `virtual_network_id` non-empty
- if `registration_enabled` exists: boolean

For private DNS record resources, validate:

- record `name` non-empty
- `zone_name` non-empty
- `resource_group_name` non-empty
- `ttl` integer > 0 when present

Type-specific:

- A/AAAA: records list length > 0
- CNAME: record non-empty
- MX/PTR/SRV/TXT: validate block/fields are present and non-empty
