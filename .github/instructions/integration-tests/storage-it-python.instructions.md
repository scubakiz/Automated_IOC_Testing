---
description: "Use when generating Python post-apply integration tests for Azure Storage Accounts that validate real Azure state."
---

# CATTS — Storage Account integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Azure Storage Accounts** that run **after** `terraform apply`.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate Storage Account-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/storage/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/storage/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `storage_account_id` (best), OR
  - `storage_account_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- If you have an ID: `az storage account show --ids <storage_account_id>`
- Otherwise: `az storage account show --name <name> --resource-group <rg>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations as separate `test_*` functions:

### Identity / policy

- `test_storage_exists`: Storage Account can be retrieved (non-null response)
- `test_storage_name_nonempty`: `name` field is non-empty
- `test_storage_location_nonempty`: `location` is non-empty
- `test_storage_location_allowed`: `location` is in allowed list — only if English policy defines **Allowed locations** (normalize: lower + remove spaces on both sides)
- `test_storage_naming_convention`: `name` matches naming regex — only if English policy defines a **Naming convention** AND it is compatible with storage account naming rules (lowercase alphanumeric only)
- `test_storage_required_tags`: required tag keys exist on `tags` — only if English policy defines **Required tags (keys)**

### Account configuration

- `test_storage_account_tier_nonempty`: `sku.tier` is non-empty
- `test_storage_account_replication_nonempty`: `sku.name` is non-empty (contains the replication type, e.g. `"Standard_LRS"`)

### Security posture (always generate — these are not optional)

- `test_storage_min_tls_version`: `minimumTlsVersion` is `"TLS1_2"`
- `test_storage_https_only`: `enableHttpsTrafficOnly` is `true`
- `test_storage_public_network_access_disabled`: `publicNetworkAccess` is `"Disabled"`
- `test_storage_allow_nested_items_public_disabled`: `allowBlobPublicAccess` is `false` (field may appear as `allowBlobPublicAccess` in some API versions)

### Encryption

- `test_storage_encryption_enabled`: `encryption.services.blob.enabled` is `true` (Azure Storage encryption is always on, but verify the response contains the field)

## File naming (required)

Under `<terraform_root>/tests/integration-tests/storage/`:

- `test_storage_basic.py` (always)

## Feature coverage checklist

Generate one dedicated `test_*` function per item above. Make every failure message actionable:

```
f"Storage Account '{name}' has minimumTlsVersion='{actual}'. Expected: 'TLS1_2'"
```

## Policy behavior (required)

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## Minimum output contract

When finished, `test_storage_basic.py` must include at minimum:

- `test_storage_exists`
- `test_storage_min_tls_version`
- `test_storage_https_only`
- `test_storage_public_network_access_disabled`
- `test_storage_allow_nested_items_public_disabled`
