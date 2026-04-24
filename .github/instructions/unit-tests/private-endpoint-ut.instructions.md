---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Private Endpoints from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Private Endpoint unit test generation (Terraform-only)


## Scope boundaries

- ONLY create tests for private endpoint objects.
  - Direct resource: `azurerm_private_endpoint`
- If modules are used, assert only on module inputs/outputs you can observe without guessing.

## Output location

- `<terraform_root>/tests/unit-tests/private-endpoint/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/private-endpoint/`

## What to assert (Private Endpoint)

For each discovered `azurerm_private_endpoint.<NAME>`:

- Name is non-empty.
- Location is non-empty.
- If allowed locations configured: `lower(location)` is in allowlist.
- Subnet id is non-empty:
  - `trimspace(azurerm_private_endpoint.<NAME>.subnet_id) != ""`
- At least one `private_service_connection` exists:
  - `length(azurerm_private_endpoint.<NAME>.private_service_connection) > 0`

## Feature coverage checklist (drive many runs)

Generate **one assert per run** for each configured attribute/block below.

### Identity / policy

- `name` non-empty.
- naming convention match only if configured.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### Subnet placement

- `subnet_id` non-empty.

### Private service connections

- `private_service_connection` exists and length > 0.
- For each connection:
  - `name` non-empty
  - `is_manual_connection` is boolean when present
  - at least one of `private_connection_resource_id` or `private_connection_resource_alias` is non-empty
  - if `subresource_names` is set: list length > 0 and all entries non-empty
  - if `request_message` is set: non-empty

### IP configurations (when present)

- If `ip_configuration` blocks exist:
  - each has `name` non-empty
  - if `private_ip_address` is set: non-empty
  - if `subresource_name` is set: non-empty
  - if `member_name` is set: non-empty

### Private DNS zone group (when present)

- If `private_dns_zone_group` exists:
  - `name` non-empty
  - `private_dns_zone_ids` length > 0 and ids non-empty

## Suggested file layout

- `naming.tftest.hcl`
- `placement.tftest.hcl`
- `connections.tftest.hcl`
- `dns.tftest.hcl` (only when dns zone group is present)

## Suggested file layout

- `naming.tftest.hcl`
- `config.tftest.hcl`

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/private-endpoint/` with `mock_provider`, a `plan` run, and an assert tied to a discovered `azurerm_private_endpoint`.
