---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Key Vault (azurerm_key_vault) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Key Vault unit test generation (Terraform-only)

## Scope boundaries (must follow)

- ONLY create tests for Key Vault-related objects.
  - Direct resources: `azurerm_key_vault`
  - Sub-resources (assert when present): `azurerm_key_vault_key`, `azurerm_key_vault_secret`, `azurerm_key_vault_certificate`, `azurerm_key_vault_access_policy`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/key-vault/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/key-vault/`

## What to assert for `azurerm_key_vault`

For each discovered Key Vault resource address `azurerm_key_vault.<NAME>`:

**Identity / naming:**

- `name` is non-empty
- `name` matches naming policy ONLY if the naming convention is configured in the English policy
- `location` is non-empty
- `location` is in the allowed list ONLY if allowed locations are configured in the English policy
- `resource_group_name` is non-empty

**SKU:**

- `sku_name` is non-empty
- `sku_name` is either `"standard"` or `"premium"` (Azure's only valid values)

**Soft-delete (security requirement):**

- `soft_delete_retention_days` is >= 7 (Azure minimum; default is 90)
- `purge_protection_enabled` is `true`

**Network access (security requirement):**

Assert one of the following (prefer both when available in the config):

- `public_network_access_enabled = false`, OR
- `network_acls[0].default_action = "Deny"` — i.e. the default deny stance is set

If neither field is present in the config, assert only that `network_acls` block exists (do not invent org rules beyond what the config declares).

**Tags:**

- If the English policy defines **Required tags (keys)**: assert each required tag key exists in the `tags` map.

## What to assert for sub-resources (only when present in the Terraform config)

### `azurerm_key_vault_key.<NAME>`

- `name` is non-empty
- `key_vault_id` is non-empty
- `key_type` is non-empty (Azure-valid values: `"EC"`, `"EC-HSM"`, `"RSA"`, `"RSA-HSM"`, `"oct"`, `"oct-HSM"`)
- `key_size` or `curve` is non-empty (one must be set depending on key type)

### `azurerm_key_vault_secret.<NAME>`

- `name` is non-empty
- `key_vault_id` is non-empty
- Do NOT assert the `value` field — it is sensitive

### `azurerm_key_vault_certificate.<NAME>`

- `name` is non-empty
- `key_vault_id` is non-empty

### `azurerm_key_vault_access_policy.<NAME>`

- `key_vault_id` is non-empty
- `tenant_id` is non-empty
- `object_id` is non-empty
- At least one of `key_permissions`, `secret_permissions`, `certificate_permissions`, `storage_permissions` is non-empty

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/key-vault/`:

- `naming.tftest.hcl` — naming, location, resource group invariants (always)
- `config.tftest.hcl` — sku, soft-delete, purge protection, network access, tags (always)

## Test names (required)

Use these canonical `run` block names:

### In `naming.tftest.hcl` (one assert per run):

- `run "key_vault_name_nonempty" { command = plan }`
- `run "key_vault_name_matches_convention" { command = plan }` (only if naming convention is configured)
- `run "key_vault_resource_group_name_nonempty" { command = plan }`
- `run "key_vault_location_nonempty" { command = plan }`
- `run "key_vault_location_allowed" { command = plan }` (only if allowed locations are configured)

### In `config.tftest.hcl` (one assert per run):

- `run "key_vault_sku_nonempty" { command = plan }`
- `run "key_vault_sku_valid" { command = plan }`
- `run "key_vault_soft_delete_retention_days_valid" { command = plan }`
- `run "key_vault_purge_protection_enabled" { command = plan }`
- `run "key_vault_network_access_restricted" { command = plan }`
- `run "key_vault_tags_required_keys" { command = plan }` (only if required tags are configured)

If multiple Key Vault resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/key-vault/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_key_vault` resource
