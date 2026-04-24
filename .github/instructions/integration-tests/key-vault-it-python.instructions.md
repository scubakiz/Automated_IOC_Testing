---
description: "Use when generating Python post-apply integration tests for Azure Key Vault that validate real Azure state."
---

# CATTS — Key Vault integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Azure Key Vault** that run **after** `terraform apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate Key Vault-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/key-vault/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/key-vault/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `key_vault_id` (best), OR
  - `key_vault_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- If you have an ID: `az keyvault show --ids <key_vault_id>`
- Otherwise: `az keyvault show --name <name> --resource-group <rg>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations as separate `test_*` functions:

### Identity / policy

- `test_key_vault_exists`: Key Vault can be retrieved (non-null response)
- `test_key_vault_name_nonempty`: `name` field is non-empty
- `test_key_vault_location_nonempty`: `location` is non-empty
- `test_key_vault_location_allowed`: `location` is in allowed list — only if English policy defines **Allowed locations** (normalize: lower + remove spaces on both sides)
- `test_key_vault_naming_convention`: `name` matches naming regex — only if English policy defines a **Naming convention**
- `test_key_vault_required_tags`: required tag keys exist on `properties.tags` — only if English policy defines **Required tags (keys)**

### SKU

- `test_key_vault_sku`: `properties.sku.name` is non-empty and one of `"standard"`, `"premium"`

### Security posture (always generate — these are not optional)

- `test_key_vault_soft_delete_enabled`: `properties.enableSoftDelete` is `true`
- `test_key_vault_soft_delete_retention_days`: `properties.softDeleteRetentionInDays` >= 7
- `test_key_vault_purge_protection_enabled`: `properties.enablePurgeProtection` is `true`
- `test_key_vault_public_network_access_disabled`: `properties.publicNetworkAccess` is `"Disabled"` OR `properties.networkAcls.defaultAction` is `"Deny"`

### RBAC vs. access policies

- `test_key_vault_auth_model`: assert `properties.enableRbacAuthorization` is either `true` or `false` (presence check only — do not enforce a specific model unless the English policy defines it)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/key-vault/`:

- `test_key_vault_basic.py` (always)

## Feature coverage checklist

Generate one dedicated `test_*` function per item above. Make every failure message actionable:

```
f"Key Vault '{name}' purge protection is not enabled. Expected: True, Got: {actual}"
```

## Policy behavior (required)

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## Minimum output contract

When finished, `test_key_vault_basic.py` must include at minimum:

- `test_key_vault_exists`
- `test_key_vault_purge_protection_enabled`
- `test_key_vault_soft_delete_enabled`
- `test_key_vault_public_network_access_disabled`
