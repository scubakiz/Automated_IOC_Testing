---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for API Management (APIM) roots/modules from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — APIM unit test generation (Terraform-only)


## Scope boundaries (must follow)

- ONLY create tests for APIM-related configuration.
  - Direct resource signal: `azurerm_api_management`
  - Module signal: `module` with source containing `avm-res-apimanagement-service` (case-insensitive)
- You MAY assert on supporting inputs that APIM depends on in the same Terraform root (networking + rg) **only when they are clearly APIM-related**.
  - Examples in many roots: `var.apim_name`, `var.apim_publisher_email`, `var.apim_publisher_name`, subnet/VNet variables.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/apim/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/apim/`

## What to assert (APIM-focused)

Generate multiple small assertions (dozens is OK) across these themes when the corresponding values are discoverable (variables exist, defaults exist, or values are set in test variables).

### APIM identity / naming

- `var.apim_name` (or equivalent) is non-empty
- If naming convention configured: APIM name matches the generated regex

### Publisher metadata

- `var.apim_publisher_email` is non-empty
- `var.apim_publisher_name` is non-empty

### Location policy

- `var.location` is non-empty
- If allowed locations configured: `lower(var.location)` is in the allowlist

### Networking prerequisites (when present in the root)

- `var.hub_vnet_name` (or equivalent) is non-empty
- `var.apim_subnet_name` is non-empty
- `var.apim_subnet_prefix` is valid CIDR: `can(cidrnetmask(var.apim_subnet_prefix))`

### Resource group inputs (when present)

- `var.resource_group_name` is non-empty
- If naming convention configured: RG name matches the generated regex

## File layout conventions (required)

Prefer multiple files over one giant file:

- `inputs.tftest.hcl` — APIM + required input invariants
- `naming.tftest.hcl` — naming convention assertions (only if policy configured)
- `networking.tftest.hcl` — subnet/VNet CIDR + non-empty checks

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/apim/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered APIM signal (direct resource or module inputs/variables)
