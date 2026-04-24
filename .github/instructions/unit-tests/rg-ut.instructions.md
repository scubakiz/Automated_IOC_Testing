---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Resource Groups (azurerm_resource_group) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Resource Group unit test generation (Terraform-only)


## Scope boundaries (must follow)

- ONLY create tests for Resource Group-related objects.
  - Direct resources: `azurerm_resource_group`
- If the folder uses modules, generate tests only when you can validate something without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/rg/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/rg/`

## What to assert for `azurerm_resource_group`

For each discovered Resource Group resource address `azurerm_resource_group.<NAME>`:

- Name is non-empty
- Name matches naming policy ONLY if the naming convention is configured in the English policy

Add these RG feature assertions (one assert per run) when values are determinable from configuration:

- Location is non-empty
- If allowed locations are configured in English policy:
  - `lower(azurerm_resource_group.<NAME>.location)` is in the allowlist

Tag policy note:

- RG tags are often set at plan-time and can be asserted when literal/known.
- However, do not invent required tag keys; only enforce required tag keys in post-apply Python validation when such tests exist for the root.

Avoid hard-coding org policy (prefixes, exact regex, tags, allowed regions) unless the repo provides it.

## File layout conventions (required)

Generate this file under `<terraform_root>/tests/unit-tests/rg/`:

- `naming.tftest.hcl` — RG naming invariants (always)

## Test names (required)

Use these canonical `run` block names in `naming.tftest.hcl` (one assert per run):

- `run "rg_name_nonempty" { command = plan }`
- `run "rg_name_matches_convention" { command = plan }` (only if naming convention is configured)

If multiple Resource Group resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/rg/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_resource_group` resource
