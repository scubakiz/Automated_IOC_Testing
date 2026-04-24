---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Public IP Addresses (pip) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Public IP (pip) unit test generation (Terraform-only)


## Scope boundaries (must follow)

- ONLY create tests for Public IP objects.
  - Direct resource: `azurerm_public_ip`
- If the Terraform root uses modules, generate tests only when you can assert on module inputs/outputs without guessing.

## Output location (required)

- `<terraform_root>/tests/unit-tests/pip/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/pip/`

## What to assert (Public IP)

For each discovered `azurerm_public_ip.<NAME>`:

- Name is non-empty.
- Location is non-empty.
- If allowed locations configured: `lower(location)` is in allowlist.
- If `allocation_method` is set: it is one of `Static`/`Dynamic`.
- If `sku` is set: it is non-empty (and optionally in `Basic`/`Standard` if the value is a literal).

## Feature coverage checklist (drive many runs)

Unit tests are `command = plan` with mocked providers, so you validate **configuration shape and invariants**, not live Azure state.

Generate **one assert per run** for each configured attribute/block below (when it exists in the Terraform config) for every discovered `azurerm_public_ip.<NAME>`.

### Identity / policy

- `name` non-empty.
- naming convention match only if English policy configures a naming convention.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### Allocation / version

- If `allocation_method` is set: it is in {"Static", "Dynamic"}.
- If `ip_version` is set: it is in {"IPv4", "IPv6"}.

### SKU / tier

- If `sku` is set: it is in {"Basic", "Standard"} when the value is a literal.
- If `sku_tier` is set: it is non-empty.

### Zones

- If `zones` is set: it is a list and length > 0.

### DNS settings

- If `domain_name_label` is set: it is non-empty.
- If `reverse_fqdn` is set: it is non-empty.

### Timeouts / prefixes

- If `idle_timeout_in_minutes` is set: it is > 0.
- If `public_ip_prefix_id` is set: it is non-empty.

### Tags

- Do NOT enforce tags at plan-time by default (often unknown or computed).
- Tag enforcement belongs in Python post-apply validation if policy defines **Required tags (keys)**.

## Suggested file layout (required)

Prefer multiple files under `<terraform_root>/tests/unit-tests/pip/`:

- `naming.tftest.hcl` — name/location/rg invariants
- `config.tftest.hcl` — allocation/sku/version/timeout/DNS invariants

Keep run names unique, e.g. `pip_allocation_method_valid__<NAME>`.

## Suggested file layout

- `naming.tftest.hcl` — name/location invariants
- `config.tftest.hcl` — allocation/sku invariants

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/pip/` that contains `mock_provider`, a `plan` run, and an assert tied to a discovered `azurerm_public_ip`.
