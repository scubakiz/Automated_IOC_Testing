---
description: "Global company policy lookup guidance for CATTS-generated unit/integration tests (naming, tagging, allowed regions). Customize to point at Work IQ, Fabric IQ, or internal policy sources."
---

# CATTS global policy instructions

These instructions are **global**. Any CATTS test-generator agent (unit or integration) should follow these rules **in addition to** its resource-specific instructions.

## Purpose

Provide a single place a customer can edit to tell CATTS:

- where company policies live (Work IQ / Fabric IQ / internal wiki)
- what the policies mean for test generation (naming, tags, allowed locations)

This file is the **single place** to define (or link to) the company policy rules CATTS should enforce in generated tests.

## Policy sources (customer editable)

Fill in the TODO values below with your real sources.

- Naming conventions source:
  - Work IQ: `<WORK_IQ_NAMING_URL>` (TODO)
  - Fabric IQ: `<FABRIC_IQ_NAMING_URL>` (TODO)
  - Other: `<INTERNAL_NAMING_POLICY_URL>` (TODO)

- Tagging policy source:
  - Work IQ: `<WORK_IQ_TAGGING_URL>` (TODO)
  - Fabric IQ: `<FABRIC_IQ_TAGGING_URL>` (TODO)
  - Other: `<INTERNAL_TAGGING_POLICY_URL>` (TODO)

- Allowed regions / geo policy source:
  - Work IQ: `<WORK_IQ_REGIONS_URL>` (TODO)
  - Fabric IQ: `<FABRIC_IQ_REGIONS_URL>` (TODO)
  - Other: `<INTERNAL_REGIONS_POLICY_URL>` (TODO)

## Local policy definitions for test generation

This section is OPTIONAL.

- If your org has **no** naming, tagging, or allowed-location requirements, leave the values in the Enforceable rules section blank. CATTS will generate only minimal safe invariants.
- If your authoritative policy is stored externally (Work IQ / Fabric IQ / wiki), keep the URL(s) above and copy the enforceable parts into the Enforceable rules section.

## Enforceable rules (English)

This is the ONLY section CATTS treats as enforceable.

Infra teams should edit ONLY the values on the right side.
CATTS parses these exact lines (labels must stay the same).

- Naming convention (human-readable): `<env>-<resource>-<region>-<instance>`
- Required tags (keys): `Environment`, `Owner`
- Allowed locations: `eastus2`, `westeurope`, `northcentralus`

## How generators must use policy sources

- Generators must NOT invent company rules.
- Generators must ONLY enforce what is explicitly present in the **Enforceable rules (English)** section.
- Generators should log into Azure to query and validate Azure policies that apply to Azure resources referenced in the terraform code before generating tests.
- If a line is missing or has no values, treat that rule as NOT configured and do not enforce it.
- Still validate minimal safe invariants (e.g., required outputs exist; names are non-empty; locations are non-empty).

## Output hygiene

- Always make failures actionable (error messages should say what policy was violated).
