---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Network Security Groups (azurerm_network_security_group) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — NSG unit test generation (Terraform-only)


## Scope boundaries (must follow)

- ONLY create tests for NSG-related objects.
  - Direct resources: `azurerm_network_security_group`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/nsg/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/nsg/`

## What to assert for `azurerm_network_security_group`

For each discovered NSG resource address `azurerm_network_security_group.<NAME>`:

- Name is non-empty
- Name matches naming policy ONLY if the naming convention is configured in the English policy
- Location is non-empty
- Resource group name is non-empty

Security rules (stable, non-policy-specific checks):

- If `security_rule` blocks exist in the config, assert there is at least 1.
- Optionally assert each `security_rule` has:
  - non-empty `name`
  - `direction` in {"Inbound","Outbound"}
  - `access` in {"Allow","Deny"}

Expand rule-shape assertions (generate one assert per run per field when the field exists in config):

- `priority` exists and is an integer (and, when literal, is within Azure's valid range 100–4096)
- `protocol` exists and is non-empty
- At least one of these source fields is set (when schema exposes them):
  - `source_port_range` or `source_port_ranges`
  - `source_address_prefix` or `source_address_prefixes`
  - `source_application_security_group_ids`
- At least one of these destination fields is set (when schema exposes them):
  - `destination_port_range` or `destination_port_ranges`
  - `destination_address_prefix` or `destination_address_prefixes`
  - `destination_application_security_group_ids`
- If `description` is set: it is non-empty

Do not hard-code required ports or priority conventions unless the repo provides them via English policy.

Avoid hard-coding org policy (required ports, priorities, etc.) unless the repo provides it.

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/nsg/`:

- `naming.tftest.hcl` — NSG naming/location/resource-group invariants (always)
- `rules.tftest.hcl` — security rule presence/basic shape checks (always)

## Test names (required)

Use these canonical `run` block names:

- In `naming.tftest.hcl` (one assert per run):
  - `run "nsg_name_nonempty" { command = plan }`
  - `run "nsg_name_matches_convention" { command = plan }` (only if naming convention is configured)
  - `run "nsg_resource_group_name_nonempty" { command = plan }`
  - `run "nsg_location_nonempty" { command = plan }`
  - `run "nsg_location_allowed" { command = plan }` (only if allowed locations are configured)
- In `rules.tftest.hcl`: `run "nsg_rules" { command = plan }`

If multiple NSG resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/nsg/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_network_security_group` resource
