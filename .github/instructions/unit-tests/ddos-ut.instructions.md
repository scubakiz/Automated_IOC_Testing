---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure DDoS Protection Plan and associations from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — DDoS Protection (ddos) unit test generation (Terraform-only)


## Scope

- `azurerm_network_ddos_protection_plan`
- `azurerm_virtual_network` blocks that set `ddos_protection_plan`

## Output

- `<terraform_root>/tests/unit-tests/ddos/*.tftest.hcl`

## Feature checklist

For each `azurerm_network_ddos_protection_plan.<NAME>`:

- name non-empty; naming regex only if configured.
- RG/location non-empty; allowed locations only if configured.

For each `azurerm_virtual_network.<NAME>` that includes `ddos_protection_plan`:

- ddos plan `id` is non-empty
- ddos `enable` is boolean when present
