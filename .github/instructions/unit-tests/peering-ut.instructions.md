---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Virtual Network Peerings (azurerm_virtual_network_peering) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — VNet peering unit test generation (Terraform-only)


## Scope boundaries (must follow)

- ONLY create tests for peering-related objects.
  - Direct resources: `azurerm_virtual_network_peering`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/peering/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/peering/`

## What to assert for `azurerm_virtual_network_peering`

For each discovered peering address `azurerm_virtual_network_peering.<NAME>`:

- `name` is non-empty
- `virtual_network_name` is non-empty
- `remote_virtual_network_id` is non-empty

Policy-controlled flags (org policy dependent):

- Assert these attributes are explicitly set (and optionally equal to an expected value):
  - `allow_virtual_network_access`
  - `allow_forwarded_traffic`
  - `allow_gateway_transit`
  - `use_remote_gateways`

Because policies vary by org, use TODOs and avoid hard-coding.

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/peering/`:

- `config.tftest.hcl` — core peering invariants and flag assertions (always)

## Test names (required)

Use descriptive `run` names (one assert per run) and keep them unique.

For each Peering resource `azurerm_virtual_network_peering.<NAME>` in `config.tftest.hcl`:

- `run "peering_name_nonempty__<NAME>" { command = plan }`
- `run "peering_virtual_network_name_nonempty__<NAME>" { command = plan }`
- `run "peering_remote_virtual_network_id_nonempty__<NAME>" { command = plan }`

If you add policy-controlled flag assertions, use one run per flag (only if the attribute exists in config), for example:

- `run "peering_allow_forwarded_traffic_explicit__<NAME>" { command = plan }`

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/peering/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_virtual_network_peering` resource
