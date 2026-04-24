---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Virtual Networks (vnet/subnet/peering) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — VNet unit test generation (Terraform-only)

## Scope boundaries (must follow)

- ONLY create tests for VNet-related objects.
  - Direct resources: `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_virtual_network_peering`.
  - If the folder uses modules (AVM or otherwise), generate tests only when you can validate something via module inputs/outputs without guessing.
- DO NOT create tests for unrelated resources.

## Output location (required)

Given a Terraform root folder (the folder CATTS is scanning), write tests to:

- `<terraform_root>/tests/unit-tests/vnet/*.tftest.hcl`

Before creating files, ensure these folders exist (create if missing):

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/vnet/`

## Inputs and discovery

### 1) Identify the Terraform root under test

- Use the folder the user pointed you at.
- Assume Terraform 1.7+ is available.

### 2) Discover VNet resources

Prefer this order:

1. Parse the folder’s `.tf` files and locate direct resources of types:
   - `azurerm_virtual_network`
   - `azurerm_subnet`
   - `azurerm_virtual_network_peering`
2. If none exist, look for module calls that are likely to create VNets (AVM or custom). In that case:
   - only generate assertions against **module outputs** that are present, OR
   - generate “input validation” tests if the module exposes input variables in this root and those map clearly to naming/addressing policy.

Do not invent module semantics.

## Known provider schema constraints (MUST follow)

### `azurerm_virtual_network.address_space` is a SET — do NOT use `[0]`

`address_space` is declared as a `set(string)` in the azurerm provider schema.
Numeric indexing (e.g., `azurerm_virtual_network.hub.address_space[0]`) causes:

```
Error: Invalid index — Elements of a set are identified only by their value and
don't have any separate index or key to select with.
```

**Required fix**: Assert on the **input variable** that drives the attribute, not the resource attribute:

```hcl
# CORRECT — assert on the variable (always known at plan time, no set-index issue)
assert {
  condition     = can(cidrhost(var.hub_vnet_address_space, 0))
  error_message = "var.hub_vnet_address_space '${var.hub_vnet_address_space}' must be a valid CIDR block."
}

# WRONG — address_space is a set; [0] throws "Invalid index" at evaluation time
# assert {
#   condition = can(cidrhost(azurerm_virtual_network.hub.address_space[0], 0))
# }
```

If you must iterate the set (e.g., for multi-CIDR validation), use `tolist()` to convert first:

```hcl
can(cidrhost(tolist(azurerm_virtual_network.hub.address_space)[0], 0))
```

But the variable-assertion approach is preferred — simpler and always known.

### `azurerm_subnet.address_prefixes` — safe as a list but prefer variable assertion

`address_prefixes` is a `list(string)` — indexing works. However, the same reasoning
applies: asserting on the input variable is simpler and avoids plan-time unknown issues.

## What to assert for VNets (policy-driven)

Use the naming convention and allowed regions described in:

- `CATTS/.github/instructions/global/policies.instructions.md`

## File layout conventions

Generate 1–3 files (avoid one giant file):

- `naming.tftest.hcl` — naming and tag policy assertions
- `addressing.tftest.hcl` — CIDR syntax / subnet prefix validations
- `peering.tftest.hcl` — peering policy assertions

## Test names (required)

Use descriptive `run` names (one assert per run) and keep them unique.

For each VNet resource `azurerm_virtual_network.<NAME>` in `naming.tftest.hcl`:

- `run "vnet_name_nonempty__<NAME>" { command = plan }`
- `run "vnet_name_matches_convention__<NAME>" { command = plan }` (only if naming convention is configured)
- `run "vnet_location_nonempty__<NAME>" { command = plan }`
- `run "vnet_location_allowed__<NAME>" { command = plan }` (only if allowed locations are configured)

For each VNet resource `azurerm_virtual_network.<NAME>` in `addressing.tftest.hcl`:

- `run "vnet_address_space_cidr_valid__<NAME>" { command = plan }`

For each Subnet resource `azurerm_subnet.<NAME>` included by this category:

- In `naming.tftest.hcl`: `run "subnet_name_nonempty__<NAME>" { command = plan }`
- In `naming.tftest.hcl`: `run "subnet_name_matches_convention__<NAME>" { command = plan }` (only if naming convention is configured)
- In `addressing.tftest.hcl`: `run "subnet_address_prefixes_cidr_valid__<NAME>" { command = plan }`

For each Peering resource `azurerm_virtual_network_peering.<NAME>` (if present) in `peering.tftest.hcl`:

- `run "peering_name_nonempty__<NAME>" { command = plan }`
- Add additional runs per-flag only if the attribute exists in config, for example:
  - `run "peering_allow_forwarded_traffic_explicit__<NAME>" { command = plan }`

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/vnet/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered VNet-related resource
