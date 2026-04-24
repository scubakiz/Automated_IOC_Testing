---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure DNS (public DNS) zones and record sets from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Azure DNS (dns) unit test generation (Terraform-only)


## Scope

- Zones: `azurerm_dns_zone`
- Record sets: `azurerm_dns_*_record`

## Output

- `<terraform_root>/tests/unit-tests/dns/*.tftest.hcl`

## Feature checklist

For each `azurerm_dns_zone.<NAME>`:

- name non-empty (DNS zone name, e.g. example.com)
- RG non-empty
- tags are not enforced at plan-time unless literal

For each DNS record resource, validate configuration shape:

- record `name` non-empty
- `zone_name` non-empty
- `resource_group_name` non-empty
- `ttl` integer > 0 when present

Then per type:

- A/AAAA: records list length > 0 and entries non-empty
- CNAME: `record` non-empty
- MX: `record` blocks have `preference` integer and `exchange` non-empty
- NS: record blocks have `nsdname` non-empty
- PTR: records list length > 0
- SRV: record blocks have port/priority/weight integers and target non-empty
- TXT: records list length > 0 and entries non-empty
