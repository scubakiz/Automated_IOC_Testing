---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Front Door (classic or Standard/Premium) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Front Door (front-door) unit test generation (Terraform-only)

Generate unit tests for **Azure Front Door**.

Use together with:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Scope boundaries

- ONLY test Front Door-related resources.
- Supported direct resources (any may appear):
  - Classic: `azurerm_frontdoor`
  - Standard/Premium: `azurerm_cdn_frontdoor_profile`, `azurerm_cdn_frontdoor_endpoint`, `azurerm_cdn_frontdoor_origin_group`, `azurerm_cdn_frontdoor_origin`, `azurerm_cdn_frontdoor_route`, `azurerm_cdn_frontdoor_custom_domain`, `azurerm_cdn_frontdoor_rule_set`, `azurerm_cdn_frontdoor_rule`, `azurerm_cdn_frontdoor_firewall_policy`, `azurerm_cdn_frontdoor_security_policy`
- Do not invent org defaults.

## Output location

- `<terraform_root>/tests/unit-tests/front-door/*.tftest.hcl`

## Test design

- `mock_provider "azurerm" {}`
- `command = plan`
- One assert per run; unique run names.

## Feature coverage checklist

Generate one run per check for each discovered Front Door resource.

### Profile / main resource

- name non-empty; naming convention if configured.
- RG/location non-empty; allowed locations if configured.
- SKU non-empty.

### Endpoints

- endpoint name non-empty
- enabled flags are boolean when present

### Origins / origin groups

- origin group name non-empty
- load balancing settings present when configured (sample size, successful samples)
- health probe settings present when configured (path/protocol/interval)
- each origin has host name non-empty and ports valid
- private link blocks (if present) have required ids non-empty

### Routes

- route name non-empty
- patterns to match list non-empty
- supported protocols list non-empty
- forwarding protocol non-empty
- caching settings valid when present
- link between route and origin group is non-empty

### Custom domains

- custom domain name non-empty
- host name non-empty
- TLS settings present when enabled (certificate type/min TLS)

### Rules engine

- rule set name non-empty
- each rule name non-empty
- for each rule: order integer; actions list non-empty when configured; conditions list non-empty when configured

### WAF / security policy

- firewall policy name non-empty
- mode non-empty when present
- managed rule set type/version non-empty when present
- custom rules: priority integer, action non-empty, match conditions non-empty
- security policy links to firewall policy id non-empty
