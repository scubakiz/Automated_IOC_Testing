---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Traffic Manager (azurerm_traffic_manager_profile/endpoints) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Traffic Manager (traffic-manager) unit test generation (Terraform-only)

Use with global policies:

- `CATTS/.github/instructions/global/policies.instructions.md`

## Scope

- ONLY test Traffic Manager profile + endpoints:
  - `azurerm_traffic_manager_profile`
  - `azurerm_traffic_manager_endpoint`

## Output

- `<terraform_root>/tests/unit-tests/traffic-manager/*.tftest.hcl`

## Feature checklist

For each `azurerm_traffic_manager_profile.<NAME>`:

- name non-empty; naming regex only if configured.
- RG non-empty.
- `traffic_routing_method` non-empty.
- `dns_config.relative_name` non-empty.
- `dns_config.ttl` integer > 0.
- `monitor_config.protocol` non-empty.
- `monitor_config.port` integer > 0.
- if `monitor_config.path` exists: non-empty.
- if `profile_status` exists: non-empty.

For each `azurerm_traffic_manager_endpoint.<NAME>`:

- name non-empty
- `profile_name` non-empty
- `type` non-empty
- `target` non-empty when present
- `endpoint_status` non-empty when present
- `weight` integer when present
- `priority` integer when present
- `geo_mappings` list non-empty when present
- `subnet` blocks, if present: have first/last or mask non-empty
