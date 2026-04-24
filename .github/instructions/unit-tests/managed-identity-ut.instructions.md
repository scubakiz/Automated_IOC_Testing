---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure User Assigned Managed Identity (azurerm_user_assigned_identity) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Managed Identity unit test generation (Terraform-only)

## Scope

This category covers **User Assigned Managed Identities** only.  
System-assigned identities are embedded in other resources and are out of scope.

## Scope boundaries (must follow)

- ONLY create tests for Managed Identity-related objects.
  - Direct resources: `azurerm_user_assigned_identity`
  - Related resources (assert when present): `azurerm_role_assignment`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/managed-identity/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/managed-identity/`

## What to assert for `azurerm_user_assigned_identity`

For each discovered identity resource address `azurerm_user_assigned_identity.<NAME>`:

**Identity / naming:**

- `name` is non-empty
- `name` matches naming policy ONLY if the naming convention is configured in the English policy
- `location` is non-empty
- `location` is in the allowed list ONLY if allowed locations are configured in the English policy
- `resource_group_name` is non-empty

**Tags:**

- If the English policy defines **Required tags (keys)**: assert each required tag key exists in the `tags` map.

## What to assert for `azurerm_role_assignment` (only when present in the Terraform config)

For each discovered role assignment resource address `azurerm_role_assignment.<NAME>`:

**Required fields (all must be non-empty):**

- `scope` is non-empty (the Azure resource ID the role is scoped to)
- `principal_id` is non-empty (the identity being granted access)
- One of `role_definition_name` or `role_definition_id` is non-empty — do NOT assert a specific role name unless the English policy mandates it

**Avoid:**

- Do NOT assert specific role names or scope patterns unless they come from the English policy.
- Do NOT assert the value of `principal_id` — it is known only at apply time.

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/managed-identity/`:

- `naming.tftest.hcl` — name, location, resource group invariants (always)
- `config.tftest.hcl` — role assignment shape, tags (always; even if only UAI tag checks are included)

## Test names (required)

Use these canonical `run` block names:

### In `naming.tftest.hcl` (one assert per run):

- `run "managed_identity_name_nonempty" { command = plan }`
- `run "managed_identity_name_matches_convention" { command = plan }` (only if naming convention is configured)
- `run "managed_identity_resource_group_name_nonempty" { command = plan }`
- `run "managed_identity_location_nonempty" { command = plan }`
- `run "managed_identity_location_allowed" { command = plan }` (only if allowed locations are configured)

### In `config.tftest.hcl` (one assert per run):

- `run "managed_identity_tags_required_keys" { command = plan }` (only if required tags are configured)
- `run "role_assignment_scope_nonempty" { command = plan }` (for each role assignment, when present)
- `run "role_assignment_principal_id_nonempty" { command = plan }` (for each role assignment, when present)
- `run "role_assignment_role_definition_nonempty" { command = plan }` (for each role assignment, when present)

If multiple identity or role assignment resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/managed-identity/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_user_assigned_identity` resource
