---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Network Watcher and flow logs from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Network Watcher (network-watcher) unit test generation (Terraform-only)

## Scope

- `azurerm_network_watcher`
- `azurerm_network_watcher_flow_log`

## Output

- `<terraform_root>/tests/unit-tests/network-watcher/*.tftest.hcl`

## Feature checklist

For each `azurerm_network_watcher.<NAME>`:

- name non-empty
- RG/location non-empty

For each `azurerm_network_watcher_flow_log.<NAME>`:

- name non-empty
- network_watcher_name non-empty
- resource_group_name non-empty
- target_resource_id non-empty
- storage_account_id non-empty
- enabled boolean when present
- retention_policy enabled/days when present
- traffic_analytics enabled/workspace ids when present
