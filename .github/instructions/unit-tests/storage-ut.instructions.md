---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Storage Accounts (azurerm_storage_account) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Storage Account unit test generation (Terraform-only)

## Scope boundaries (must follow)

- ONLY create tests for Storage Account-related objects.
  - Direct resources: `azurerm_storage_account`
  - Sub-resources (assert when present): `azurerm_storage_container`, `azurerm_storage_management_policy`, `azurerm_storage_account_network_rules`
- If the folder uses modules, generate tests only when you can validate something via module inputs/outputs without guessing.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/unit-tests/storage/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/storage/`

## Naming constraint (important)

Storage account names are subject to special Azure constraints:

- 3–24 characters
- Lowercase letters and numbers ONLY (no hyphens, underscores, or uppercase)

When the English policy defines a naming convention, generate a naming assertion only if the convention is compatible with storage account naming rules. If the convention contains hyphens or uppercase segments, skip the naming assertion and emit a comment explaining the incompatibility.

## What to assert for `azurerm_storage_account`

For each discovered storage account resource address `azurerm_storage_account.<NAME>`:

**Identity / naming:**

- `name` is non-empty
- `name` matches naming policy ONLY if the naming convention is configured in the English policy AND is compatible with storage naming rules (see above)
- `location` is non-empty
- `location` is in the allowed list ONLY if allowed locations are configured in the English policy
- `resource_group_name` is non-empty

**Account configuration:**

- `account_tier` is non-empty (Azure-valid values: `"Standard"`, `"Premium"`)
- `account_replication_type` is non-empty (Azure-valid values: `"LRS"`, `"GRS"`, `"RAGRS"`, `"ZRS"`, `"GZRS"`, `"RAGZRS"`)
- `account_kind` is non-empty when explicitly set (Azure-valid values: `"BlobStorage"`, `"BlockBlobStorage"`, `"FileStorage"`, `"Storage"`, `"StorageV2"`)

**Security posture (always assert — these are security requirements):**

- `min_tls_version` is `"TLS1_2"` (TLS 1.0 and 1.1 are deprecated)
- `https_traffic_only_enabled` is `true` (Azure attribute name; Terraform attribute: `enable_https_traffic_only` in older provider versions — use whichever matches the config)
- `public_network_access_enabled` is `false`
- `allow_nested_items_to_be_public` is `false` (prevents anonymous blob access)

**Tags:**

- If the English policy defines **Required tags (keys)**: assert each required tag key exists in the `tags` map.

## What to assert for sub-resources (only when present in the Terraform config)

### `azurerm_storage_container.<NAME>`

- `name` is non-empty
- `storage_account_name` is non-empty
- `container_access_type` is `"private"` (assert this as a security posture check; do not allow `"blob"` or `"container"` without explicit policy override)

### `azurerm_storage_account_network_rules.<NAME>`

- `default_action` is `"Deny"` (deny-by-default stance)
- `storage_account_id` is non-empty

### `azurerm_storage_management_policy.<NAME>`

- `storage_account_id` is non-empty
- At least one `rule` block is defined

## File layout conventions (required)

Generate these files under `<terraform_root>/tests/unit-tests/storage/`:

- `naming.tftest.hcl` — name, location, resource group invariants (always)
- `config.tftest.hcl` — TLS, HTTPS-only, public access, allow-public-blob, account_tier, tags (always)

## Test names (required)

Use these canonical `run` block names:

### In `naming.tftest.hcl` (one assert per run):

- `run "storage_name_nonempty" { command = plan }`
- `run "storage_name_matches_convention" { command = plan }` (only if naming convention is configured AND compatible)
- `run "storage_resource_group_name_nonempty" { command = plan }`
- `run "storage_location_nonempty" { command = plan }`
- `run "storage_location_allowed" { command = plan }` (only if allowed locations are configured)

### In `config.tftest.hcl` (one assert per run):

- `run "storage_min_tls_version" { command = plan }`
- `run "storage_https_traffic_only" { command = plan }`
- `run "storage_public_network_access_disabled" { command = plan }`
- `run "storage_allow_nested_items_public_disabled" { command = plan }`
- `run "storage_account_tier_nonempty" { command = plan }`
- `run "storage_account_replication_type_nonempty" { command = plan }`
- `run "storage_tags_required_keys" { command = plan }` (only if required tags are configured)

If multiple storage account resources exist, suffix each run name with `__<resource_name>`.

## Minimum output contract

When finished, you must have created at least one `.tftest.hcl` file under:

- `<terraform_root>/tests/unit-tests/storage/`

Each file must:

- include `mock_provider "azurerm" {}`
- have at least one `run` block with `command = plan`
- contain at least one `assert` tied to a discovered `azurerm_storage_account` resource
