---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Firewall resources from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Azure Firewall unit test generation (Terraform-only)


## Scope boundaries

- ONLY create tests for firewall objects.
  - Direct resource: `azurerm_firewall`
- If modules are used, assert only on module inputs/outputs you can observe without guessing.

## Output location

- `<terraform_root>/tests/unit-tests/firewall/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/firewall/`

## What to assert (Firewall)

For each discovered `azurerm_firewall.<NAME>`:

- Name is non-empty.
- Location is non-empty.
- If allowed locations configured: `lower(location)` is in allowlist.
- Ensure at least one IP configuration exists:
  - `length(azurerm_firewall.<NAME>.ip_configuration) > 0`
- If `sku_name` / `sku_tier` are set: they are non-empty.

## Feature coverage checklist (drive many runs)

Generate **one assert per run** for each configured attribute/block below for every discovered `azurerm_firewall.<NAME>`.

### Identity / policy

- `name` non-empty.
- naming convention match only if configured.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### SKU / tier / threat intel / policy linkage

- If `sku_name` is set: non-empty.
- If `sku_tier` is set: non-empty.
- If `threat_intel_mode` is set: non-empty.
- If `firewall_policy_id` is set: non-empty.

### IP configuration blocks

- `ip_configuration` exists and length > 0.
- For each ip configuration:
  - `name` non-empty
  - `subnet_id` non-empty
  - if `public_ip_address_id` is set: non-empty

### Management IP configuration (when present)

- If `management_ip_configuration` exists:
  - `name` non-empty
  - `subnet_id` non-empty
  - `public_ip_address_id` non-empty

### Optional settings

- If `dns_servers` is set: list length > 0 and all entries non-empty.
- If `private_ip_ranges` is set: list length > 0.
- If `zones` is set: list length > 0.

### Related firewall rule resources (include when discovered)

Depending on how the root is authored, firewall “features” may be separate resources. If present, treat them as Azure Firewall feature coverage:

- `azurerm_firewall_network_rule_collection`
- `azurerm_firewall_application_rule_collection`
- `azurerm_firewall_nat_rule_collection`
- `azurerm_firewall_policy`
- `azurerm_firewall_policy_rule_collection_group`

For each discovered rule collection resource, validate:

- name non-empty
- firewall/policy association id non-empty
- priority is an integer
- action/direction/protocol fields are non-empty

Avoid inventing org-required rules.

## Suggested file layout

- `naming.tftest.hcl`
- `config.tftest.hcl`
- `ip_config.tftest.hcl`
- `rules.tftest.hcl` (only when related rule resources exist)

## Suggested file layout

- `naming.tftest.hcl`
- `config.tftest.hcl`

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/firewall/` with `mock_provider`, a `plan` run, and an assert tied to a discovered `azurerm_firewall`.
