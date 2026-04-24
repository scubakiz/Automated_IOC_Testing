---
description: "Use when generating Terraform-only unit tests (.tftest.hcl) for Subnet service endpoints configuration from an existing Terraform folder."
---

Use together with global common rules:

- `CATTS/.github/instructions/global/terraform-ut-common.instructions.md`
- `CATTS/.github/instructions/global/policies.instructions.md`

# CATTS — Service Endpoints unit test generation (Terraform-only)

Generate unit tests for **subnet service endpoints configuration** using `terraform test` (`command = plan`, mocked providers).


## Scope boundaries

- ONLY create tests for service endpoint configuration.
  - Resource signal: `azurerm_subnet_service_endpoint_storage_policy`
  - Config signal: `azurerm_subnet` blocks containing `service_endpoints = [`

## Output location

- `<terraform_root>/tests/unit-tests/service-endpoints/*.tftest.hcl`

Ensure these folders exist:

- `<terraform_root>/tests/unit-tests/`
- `<terraform_root>/tests/unit-tests/service-endpoints/`

## What to assert (Service endpoints)

When `azurerm_subnet.<NAME>.service_endpoints` exists:

- It is not empty:
  - `length(azurerm_subnet.<NAME>.service_endpoints) > 0`

When `azurerm_subnet_service_endpoint_storage_policy.<NAME>` exists:

- Subnet id is non-empty (if attribute is present): `trimspace(subnet_id) != ""`.

## Feature coverage checklist (drive many runs)

Service endpoints can be set either via the subnet block or via separate policy resources.

When `azurerm_subnet.<NAME>.service_endpoints` exists:

- Assert the list is non-empty.
- Assert every entry is a non-empty string.
- If the list is a literal list in config, generate per-entry assertions (one run per entry) so failures pinpoint the exact missing/empty service.

When `azurerm_subnet_service_endpoint_storage_policy.<NAME>` exists:

- Validate required identifiers are non-empty.
- If the policy config includes booleans/enums, validate they are set to allowed values.

Do not enforce specific endpoint service names unless they are explicitly configured in the Terraform root (do not invent org defaults).

## Suggested file layout

- `config.tftest.hcl`

## Minimum output contract

Create at least one `.tftest.hcl` file under `<terraform_root>/tests/unit-tests/service-endpoints/` with `mock_provider`, a `plan` run, and an assert tied to a discovered service endpoint signal.
