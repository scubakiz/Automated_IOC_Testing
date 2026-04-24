---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Web Application Firewall (WAF) policies/configuration from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Web Application Firewall (waf) unit test generation (Terraform-only)

WAF can appear as:

- Dedicated WAF policies (`azurerm_web_application_firewall_policy`, `azurerm_cdn_frontdoor_firewall_policy`)
- WAF configuration inside `azurerm_application_gateway` (`waf_configuration` block)


## Output

- `<terraform_root>/tests/unit-tests/waf/*.tftest.hcl`

## Feature checklist (no invented security policy)

For each `azurerm_web_application_firewall_policy.<NAME>` (when present):

- name non-empty; naming regex only if configured.
- RG/location non-empty; allowed-locations only if configured.
- `policy_settings.mode` non-empty when present.
- `policy_settings.enabled` boolean when present.
- `managed_rules` present when configured.
  - managed rule set type/version non-empty
  - exclusions blocks have match variable/operator/selector non-empty
- `custom_rules` present when configured.
  - each custom rule name non-empty
  - priority integer
  - rule_type non-empty
  - action non-empty
  - match_conditions exist and each has operator/variables/values non-empty

For each `azurerm_cdn_frontdoor_firewall_policy.<NAME>` (when present):

- name non-empty
- mode non-empty
- managed rule sets present when configured
- custom rules present when configured

For each `azurerm_application_gateway.<NAME>` WAF block (when present):

- `waf_configuration.enabled` boolean
- if enabled: `firewall_mode` non-empty
- rule set type/version non-empty when present
- request limits positive when present
