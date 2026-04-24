---
description: "Use when generating Python post-apply integration tests for Azure User Assigned Managed Identity that validate real Azure state."
---

# CATTS — Managed Identity integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Azure User Assigned Managed Identity** that run **after** `terraform apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope

User Assigned Managed Identities only. System-assigned identities are out of scope.

## Scope boundaries

- ONLY validate `azurerm_user_assigned_identity` (and `azurerm_role_assignment` outputs when present).
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/managed-identity/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/managed-identity/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `managed_identity_id` (best), OR
  - `managed_identity_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- By ID: `az identity show --ids <identity_id>`
- By name: `az identity show --name <name> --resource-group <rg>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations as separate `test_*` functions:

### Identity / policy

- `test_managed_identity_exists`: Identity can be retrieved (non-null response)
- `test_managed_identity_name_nonempty`: `name` field is non-empty
- `test_managed_identity_location_nonempty`: `location` is non-empty
- `test_managed_identity_location_allowed`: `location` is in allowed list — only if English policy defines **Allowed locations** (normalize: lower + remove spaces on both sides)
- `test_managed_identity_naming_convention`: `name` matches naming regex — only if English policy defines a **Naming convention**
- `test_managed_identity_required_tags`: required tag keys exist on `tags` — only if English policy defines **Required tags (keys)**

### Computed fields (prove full provisioning)

- `test_managed_identity_client_id_nonempty`: `clientId` is non-empty (UUID format expected)
- `test_managed_identity_principal_id_nonempty`: `principalId` is non-empty (UUID format expected)
- `test_managed_identity_tenant_id_nonempty`: `tenantId` is non-empty

### Type

- `test_managed_identity_type`: `type` is `"Microsoft.ManagedIdentity/userAssignedIdentities"` (confirms correct resource type was provisioned)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/managed-identity/`:

- `test_managed_identity_basic.py` (always)

## Feature coverage checklist

Generate one dedicated `test_*` function per item above. Make every failure message actionable:

```
f"Managed Identity '{name}' clientId is empty. Identity may not be fully provisioned."
```

## Policy behavior (required)

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## Minimum output contract

When finished, `test_managed_identity_basic.py` must include at minimum:

- `test_managed_identity_exists`
- `test_managed_identity_client_id_nonempty`
- `test_managed_identity_principal_id_nonempty`
