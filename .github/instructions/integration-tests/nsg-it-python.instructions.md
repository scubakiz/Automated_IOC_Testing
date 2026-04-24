---
description: "Use when generating Python integration test scripts for Network Security Groups that run after terraform apply and validate real Azure state."
---

# CATTS — NSG integration tests (Python)

These instructions define how an agent should generate Python-based integration tests for **Network Security Groups**.

Use together with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`
- `CATTS/.github/instructions/global/python-it-common.instructions.md`

These tests run after `terraform apply` in CI/CD.

## Scope boundaries

- ONLY validate NSG-related resources.
- Do not attempt to deploy infrastructure from Python.
- Prefer reading identifiers from Terraform outputs.

## Output location (required)

Write Python tests to:

- `<terraform_root>/tests/integration-tests/nsg/`

Ensure these folders exist:

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/nsg/`
- `<terraform_root>/tests/integration-tests/nsg/`

## Required runtime contract

Generated Python tests must:

- Load Terraform outputs via `terraform output -json`.
- Prefer outputs containing:
  - `nsg_id` (best), OR
  - `nsg_name` + `resource_group_name`

If required outputs are missing, fail with a clear error listing required outputs.

## Azure query approach

Use Azure CLI (lowest dependency):

- If you have an ID: `az network nsg show --ids <nsg_id>`
- Otherwise: `az network nsg show -g <rg> -n <nsg_name>`
- Windows compatibility: Azure CLI often resolves to `az.cmd`; invoke via `cmd.exe /c az ...`.

## Assertions to implement

Implement stable validations:

- NSG exists
- NSG location is non-empty
- If the English policy defines **Allowed locations**, assert the NSG location is in that allowlist
- If the English policy defines **Required tags (keys)**, assert those tag keys exist
- If the English policy defines a **Naming convention (human-readable)**, assert the NSG name follows it
- Optional: if rules are returned, assert rule collection is present (avoid hard-coded org policy)

Policy behavior (required):

- If `CATTS/.github/instructions/global/policies.instructions.md` is missing, OR the enforceable English lines are missing/blank, treat policy as "not configured" and do not fail solely for that.
- Only enforce policy rules when their corresponding English line has values.

## File naming (required)

Under `<terraform_root>/tests/integration-tests/nsg/`:

- `test_nsg_basic.py` (always)

## Feature coverage checklist (generate many tests)

When the Azure response contains these fields (or when Terraform outputs provide expected values), generate dedicated `test_*` functions for each item.

### Identity / policy

- `name` is non-empty; enforce naming convention only if the English policy defines it.
- `location` is non-empty; enforce allowlist only if policy defines **Allowed locations**.
- If policy defines **Required tags (keys)**: required tag keys exist on `tags`.

### NSG rules (no invented org policy)

From `securityRules` (customer-defined rules):

- Assert the list exists.
- If Terraform outputs provide expected rule names (e.g., `nsg_rule_names`), assert each expected name exists.
- For each returned rule, validate _shape_ (not org policy):
  - `name` non-empty
  - `priority` is an integer
  - `direction` in {Inbound, Outbound}
  - `access` in {Allow, Deny}
  - `protocol` is non-empty (Azure uses values like `Tcp`, `Udp`, `Icmp`, `Esp`, `Ah`, `*`)
  - at least one source selector exists (`sourceAddressPrefix` or `sourceAddressPrefixes` or `sourceApplicationSecurityGroups`)
  - at least one destination selector exists (`destinationAddressPrefix` or `destinationAddressPrefixes` or `destinationApplicationSecurityGroups`)
  - at least one port selector exists (single or ranges)

From `defaultSecurityRules` (Azure defaults):

- Do not enforce counts or specific defaults (can vary), but you may assert it is present (if returned) to prove the response is complete.