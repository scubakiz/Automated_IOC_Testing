---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Private DNS Resolver resources from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Private DNS Resolver (private-dns-resolver) unit test generation (Terraform-only)

## Scope

- `azurerm_private_dns_resolver`
- inbound/outbound endpoints
- dns forwarding rulesets, rules, vnet links

## Output

- `<terraform_root>/tests/unit-tests/private-dns-resolver/*.tftest.hcl`

## Feature checklist

Resolver:

- name non-empty
- RG/location non-empty
- `virtual_network_id` non-empty

Inbound endpoint:

- name non-empty
- resolver_name non-empty
- ip_configurations exist and have subnet_id non-empty

Outbound endpoint:

- name non-empty
- subnet_id non-empty

Ruleset:

- name non-empty
- outbound_endpoint_ids length > 0

Forwarding rule:

- name non-empty
- ruleset_name non-empty
- domain_name non-empty
- target_dns_servers length > 0 and each has ip_address non-empty

VNet link:

- name non-empty
- virtual_network_id non-empty
