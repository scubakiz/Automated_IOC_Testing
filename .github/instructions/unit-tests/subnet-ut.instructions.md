---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Subnets (azurerm_subnet) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Subnet unit test generation (Terraform-only)

## Scope boundaries (must follow)

- ONLY create tests for Subnet-related objects.
  - Direct resources: `azurerm_subnet`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/subnet/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/subnet/`

## What to assert for `azurerm_subnet`

For each discovered Subnet resource address `azurerm_subnet.<NAME>`:

- Name is non-empty
- Name matches naming policy ONLY if the naming convention is configured in the English policy
  - Example: `can(regex(<generated_regex_from_policy>, lower(azurerm_subnet.<NAME>.name)))`
- Address prefixes are syntactically valid CIDR(s)
  - `alltrue([for cidr in azurerm_subnet.<NAME>.address_prefixes : can(cidrnetmask(cidr))])`

Optionally (assert only if set in config):

- `private_endpoint_network_policies` value is explicitly set
- `private_link_service_network_policies_enabled` value is explicitly set
- `service_endpoints` is explicitly defined (org policy dependent; keep TODO)

## Feature coverage checklist (drive many runs)

Generate **one assert per run** for each configured attribute/block below for every discovered `azurerm_subnet.<NAME>`.

### Identity / policy

- `name` non-empty; naming convention only if configured.
- `resource_group_name` non-empty.
- `virtual_network_name` non-empty.

### Addressing

- `address_prefixes` exists and every entry is syntactically valid CIDR.
- If `address_prefix` (singular) is used in this root’s schema pattern, treat similarly.

### Service endpoints

- If `service_endpoints` is present:
  - list length > 0
  - every entry non-empty
  - if the list is a literal list: generate per-entry asserts (one run per entry)

### Delegations

- If `delegation` blocks exist:
  - each has `name` non-empty
  - `service_delegation.name` non-empty
  - if `service_delegation.actions` exists: list length > 0 and entries non-empty

### Network policy flags

- If `private_endpoint_network_policies` exists: it is non-empty.
- If `private_link_service_network_policies_enabled` exists: it is boolean.
- If `private_endpoint_network_policies_enabled` exists (alternate schema): it is boolean.

### Relationships (include when discovered)

**IMPORTANT — plan-time unknown values:** `azurerm_subnet_network_security_group_association` and `azurerm_subnet_route_table_association` expose `subnet_id` and association IDs that are cross-resource references resolved at apply time. These values are **unknown** during a `command = plan` run with a mocked provider, so `trimspace()` or `!= ""` assertions on them will always fail.

- Do **NOT** generate `run` blocks that assert `subnet_id`, `network_security_group_id`, or `route_table_id` on association resources in unit tests.
- Instead, add a comment noting that association correctness is validated by the Python integration tests.

Avoid inventing required services/endpoints/policies.

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/subnet/`:

- `naming.tftest.hcl` — subnet naming assertions (always)
- `addressing.tftest.hcl` — subnet CIDR syntax validations (always)

## Test names (required)

Use descriptive `run` names (one assert per run) and keep them unique.

For each Subnet resource `azurerm_subnet.<NAME>`:

- In `naming.tftest.hcl`:
  - `run "subnet_name_nonempty__<NAME>" { command = plan }`
  - `run "subnet_name_matches_convention__<NAME>" { command = plan }` (only if naming convention is configured)
- In `addressing.tftest.hcl`:
  - `run "subnet_address_prefixes_cidr_valid__<NAME>" { command = plan }`

If you add optional subnet policy knob assertions, use one run per knob, for example:

- `run "subnet_private_endpoint_network_policies_explicit__<NAME>" { command = plan }`

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/subnet/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_subnet` resource
