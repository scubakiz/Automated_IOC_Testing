---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Network Interfaces (nic) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Network Interface (nic) unit test generation (Terraform-only)


## Scope boundaries

- ONLY create tests for NIC objects.
  - Direct resource: `azurerm_network_interface`
- If the Terraform root uses modules, generate tests only when you can assert on module inputs/outputs without guessing.

## Output location

- `<terraform_root>/tests/unit-tests/nic/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/nic/`

## What to assert (NIC)

For each discovered `azurerm_network_interface.<NAME>`:

- Name is non-empty.
- Location is non-empty.
- If allowed locations configured: `lower(location)` is in allowlist.
- Ensure at least one `ip_configuration` exists:
  - `length(azurerm_network_interface.<NAME>.ip_configuration) > 0`
- If subnet id is configured via `ip_configuration.subnet_id`, assert it is non-empty.

## Feature coverage checklist (drive many runs)

Generate **one assert per run** for each configured attribute/block below for every discovered `azurerm_network_interface.<NAME>`.

### Identity / policy

- `name` non-empty.
- naming convention match only if configured.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### Feature flags

- If `enable_accelerated_networking` is set: it is boolean.
- If `enable_ip_forwarding` is set: it is boolean.
- If `dns_servers` is set: list length > 0 and all entries non-empty.

### IP configuration blocks

- `ip_configuration` exists and length > 0.
- For each `ip_configuration[i]`:
  - `name` non-empty
  - if `subnet_id` is present: non-empty
  - if `private_ip_address_allocation` is present: in {"Dynamic", "Static"}
  - if `private_ip_address_version` is present: in {"IPv4", "IPv6"}
  - if `private_ip_address` is set: non-empty
  - if `public_ip_address_id` is set: non-empty
  - if `primary` is set: boolean
  - if `gateway_load_balancer_frontend_ip_configuration_id` is set: non-empty
  - if `application_security_group_ids` is set: list length > 0
  - if `load_balancer_backend_address_pool_ids` is set: list length > 0
  - if `load_balancer_inbound_nat_rules_ids` is set: list length > 0

### Relationships (only when related resources are discovered)

If the Terraform root also contains these NIC-related resources, include them as part of NIC feature coverage:

- `azurerm_network_interface_security_group_association`
  - assert `network_interface_id` non-empty
  - assert `network_security_group_id` non-empty

## Suggested file layout

- `naming.tftest.hcl`
- `ip_config.tftest.hcl`
- `associations.tftest.hcl` (only when association resources exist)

## Suggested file layout

- `naming.tftest.hcl`
- `config.tftest.hcl`

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/nic/` with `mock_provider`, a `plan` run, and an assert tied to a discovered `azurerm_network_interface`.
