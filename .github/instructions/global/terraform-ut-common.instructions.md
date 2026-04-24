---
description: "Common rules for ALL CATTS-generated Terraform unit test (.tftest.hcl) files. Apply together with the resource-specific UT instructions."
applyTo: "**/tests/unit-tests/**/*.tftest.hcl"
---

# CATTS — Terraform unit test common rules

These rules apply to **every** resource-specific Terraform unit test generator. The resource-specific instructions file identifies which Azure resource type(s) to target and what to assert. These common rules define HOW to generate every test file.

## What unit tests mean here

- `command = plan` runs only — no real Azure calls are made
- `mock_provider "azurerm" {}` so infrastructure is never deployed
- Assertions about naming / addressing / tags / configuration that can be validated from Terraform plan output alone

## Infrastructure code rule (required)

- DO NOT modify Terraform infrastructure code (`*.tf`) unless explicitly requested.
- All test-only code belongs under `<terraform_root>/tests/`.

## Test design principles (required)

- Always include `mock_provider "azurerm" {}` at the top of each `.tftest.hcl` file.
- Use a top-level `variables { ... }` block to supply minimal safe values for any required root variables.
- All runs must use `command = plan`.
- Every `assert` must have a specific `error_message` — never leave it blank or generic.
- When checking for non-empty strings, prefer `trimspace(x) != ""` (not `trim(x)`).

## Diagnostic requirement (required)

- Prefer **one assert per run** so `terraform test` output clearly identifies exactly which check failed, even without verbose flags.
- Keep `run` block names unique within a file. When multiple resources of the same type exist, append a stable identifier using a double-underscore suffix, e.g. `vnet_name_nonempty__hub`, `nsg_name_nonempty__apim`.
- Always use descriptive `run` names that indicate what is being checked.
- When returning an error message, include the resource type, property name and value(s) checked e.g. "Expected azurerm_subnet address_prefixes not a valid CIDR block. Got: [${join(", ", azurerm_subnet.example.address_prefixes)}]"

## `locals {}` limitation (required)

Terraform `.tftest.hcl` does **not** support `locals {}`. Do not generate `locals` blocks in test files.

## Policy-driven behavior (required)

Always read the **Enforceable rules (English)** section in `CATTS/.github/instructions/global/policies.instructions.md` before generating naming or location assertions.

- If the naming convention line is **present and non-empty**: generate a regex-based naming assertion by translating tokens to regex segments. `<region>` must be constrained to the **Allowed locations** list when configured.
- If the naming convention line is **missing or blank**: do NOT generate regex-based naming assertions — only assert "name is non-empty."
- Do **NOT** hard-code sample regexes or sample region values; use only what the English policy lines define.
- If the allowed locations list is **present and non-empty**: assert `lower(var.location)` is in the list.
- If the allowed locations list is **missing or blank**: only assert that location is non-empty.
