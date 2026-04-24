---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Load Balancers (lb) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Load Balancer (lb) unit test generation (Terraform-only)


## Scope boundaries

- ONLY create tests for load balancer objects.
  - Direct resource: `azurerm_lb`
- If the Terraform root uses modules, generate tests only when you can assert on module inputs/outputs without guessing.

## Output location

- `<terraform_root>/tests/unit-tests/lb/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/lb/`

## What to assert (Load Balancer)

For each discovered `azurerm_lb.<NAME>`:

- Name is non-empty.
- Location is non-empty.
- If allowed locations configured: `lower(location)` is in allowlist.
- If `sku` is set: it is non-empty (and optionally in `Basic`/`Standard` when the value is a literal).
- Ensure it has at least one frontend IP configuration:
  - `length(azurerm_lb.<NAME>.frontend_ip_configuration) > 0`

## Feature coverage checklist (drive many runs)

Generate **one assert per run** for each configured attribute/block below.

### Identity / policy

- `name` non-empty.
- naming convention match only if configured.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### SKU

- If `sku` is set: in {"Basic", "Standard"} when literal.

### Frontend IP configurations

- `frontend_ip_configuration` exists and length > 0.
- For each frontend config:
  - `name` non-empty
  - exactly one of `subnet_id` or `public_ip_address_id` is set (when both attributes exist)
  - if `private_ip_address_allocation` exists: in {"Dynamic", "Static"}
  - if `private_ip_address` exists and allocation is Static: non-empty
  - if `zones` exists: list length > 0

### Related Load Balancer resources (include when discovered)

Load balancer “features” are often modeled as separate Terraform resources. If these are present in the Terraform root, generate unit tests for them as LB feature coverage:

- `azurerm_lb_backend_address_pool`
- `azurerm_lb_probe`
- `azurerm_lb_rule`
- `azurerm_lb_nat_rule`
- `azurerm_lb_nat_pool`
- `azurerm_lb_outbound_rule`
- `azurerm_lb_backend_address_pool_address`

For each discovered related resource:

- required id/name fields non-empty
- references back to `azurerm_lb.*` are non-empty
- validate enumerations when set (protocol, floating IP enablement, etc.)

## Suggested file layout

- `naming.tftest.hcl`
- `frontend_ip.tftest.hcl`
- `rules_and_pools.tftest.hcl` (only when related resources exist)

## Suggested file layout

- `naming.tftest.hcl`
- `config.tftest.hcl`

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/lb/` with `mock_provider`, a `plan` run, and an assert tied to a discovered `azurerm_lb`.
