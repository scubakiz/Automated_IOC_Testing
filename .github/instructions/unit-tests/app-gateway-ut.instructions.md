---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Azure Application Gateway (azurerm_application_gateway) from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Application Gateway (app-gateway) unit test generation (Terraform-only)

Generate **Terraform Testing Framework** unit tests (`terraform test`) for **Azure Application Gateway**.


## Scope boundaries (must follow)

- ONLY create tests for Application Gateway-related objects.
  - Primary resource: `azurerm_application_gateway`
  - Supporting resources are usually nested blocks (backend pools, listeners, routing rules, SSL certs, probes, rewrite/rules, identity, WAF config) inside the gateway resource.
- If the Terraform root uses modules, generate tests only when you can assert on module inputs/outputs without guessing.

## Output location (required)

- `<terraform_root>/tests/unit-tests/app-gateway/*.tftest.hcl`

Ensure folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/app-gateway/`

## Feature coverage checklist (drive hundreds of runs)

For each discovered `azurerm_application_gateway.<NAME>`, generate one run per check below **when that attribute/block exists in the Terraform config**.

### Identity / policy

- `name` non-empty; naming convention match only if configured.
- `resource_group_name` non-empty.
- `location` non-empty; allowed-locations only if configured.

### SKU / autoscale / zones

- If `sku.name` exists: non-empty.
- If `sku.tier` exists: non-empty.
- If `capacity` is set: it is > 0.
- If `autoscale_configuration` exists:
  - `min_capacity` is set and >= 0
  - if `max_capacity` exists: `max_capacity >= min_capacity`
- If `zones` exists: list length > 0.

### Network placement

- `gateway_ip_configuration` exists and length > 0.
- For each gateway ip config:
  - `name` non-empty
  - `subnet_id` non-empty

### Frontend

- `frontend_port` exists and length > 0.
- For each frontend port:
  - `name` non-empty
  - `port` is an integer > 0

- `frontend_ip_configuration` exists and length > 0.
- For each frontend IP config:
  - `name` non-empty
  - either `public_ip_address_id` non-empty OR `private_ip_address` non-empty (when present)
  - if `private_ip_address_allocation` exists: in {"Dynamic","Static"}

### Backend

- `backend_address_pool` exists and length > 0.
- For each pool:
  - `name` non-empty
  - if `fqdns` exists: list entries non-empty
  - if `ip_addresses` exists: list entries non-empty

- `backend_http_settings` exists and length > 0.
- For each http settings:
  - `name` non-empty
  - `protocol` non-empty
  - `port` integer > 0
  - if `cookie_based_affinity` exists: non-empty
  - if `request_timeout` exists: integer > 0
  - if `host_name` exists: non-empty
  - if `probe_name` exists: non-empty

### Probes

- If `probe` blocks exist:
  - each has `name` non-empty
  - `protocol` non-empty
  - if `path` exists: non-empty
  - if `interval` exists: integer > 0
  - if `timeout` exists: integer > 0
  - if `unhealthy_threshold` exists: integer > 0

### Listeners / routing

- `http_listener` exists and length > 0.
- For each listener:
  - `name` non-empty
  - `frontend_ip_configuration_name` non-empty
  - `frontend_port_name` non-empty
  - `protocol` non-empty
  - if `host_name` or `host_names` exists: non-empty
  - if `ssl_certificate_name` exists: non-empty
  - if `require_sni` exists: boolean

- Routing rules:
  - If `request_routing_rule` exists: length > 0
  - For each rule:
    - `name` non-empty
    - `rule_type` non-empty
    - `http_listener_name` non-empty
    - if `backend_address_pool_name` exists: non-empty
    - if `backend_http_settings_name` exists: non-empty
    - if `url_path_map_name` exists: non-empty
    - if `priority` exists: integer

- If `url_path_map` exists:
  - `name` non-empty
  - default pool/settings names non-empty
  - each `path_rule` has name + paths non-empty

### TLS / certificates

- If `ssl_certificate` exists:
  - `name` non-empty
  - exactly one of `data` or `key_vault_secret_id` is set (when present)
- If `ssl_policy` exists:
  - `policy_type` non-empty
  - if `policy_name` exists: non-empty
  - if `cipher_suites` exists: list length > 0
  - if `min_protocol_version` exists: non-empty

### Identity

- If `identity` exists:
  - `type` non-empty
  - if `identity_ids` exists: list length > 0

### WAF configuration (if present)

- If `waf_configuration` exists:
  - `enabled` boolean
  - if enabled: `firewall_mode` non-empty
  - if `rule_set_type` exists: non-empty
  - if `rule_set_version` exists: non-empty
  - if `file_upload_limit_mb` exists: integer > 0
  - if `max_request_body_size_kb` exists: integer > 0

### Diagnostics

- If `http2_enabled` exists: boolean.
- If `fips_enabled` exists: boolean.

## Suggested file layout

- `naming.tftest.hcl`
- `networking.tftest.hcl`
- `frontend_backend.tftest.hcl`
- `routing.tftest.hcl`
- `tls_and_waf.tftest.hcl`
