---
description: "Use when generating integration tests for Virtual Networks using only Terraform's native testing framework (terraform test, .tftest.hcl) against a real Azure subscription."
---

# CATTS — VNet integration tests (Terraform Testing Framework only)

These instructions define how an agent should generate **integration tests** for VNets using **only** the Terraform Testing Framework (`terraform test`).

These resource-specific instructions are designed to be used together with the global policies in:

- `CATTS/.github/instructions/global/policies.instructions.md`

Integration tests here mean:

- `terraform test` runs that **authenticate to Azure** and perform `command = apply`
- Assertions validate **real Azure state** (preferably via `data` sources or outputs)

## Scope boundaries

- ONLY validate VNet-related resources.
- DO NOT add unrelated resources to “help” assertions.
- Prefer tests that are safe and clean up after themselves.

## Output location (required)

Write tests to:

- `<terraform_root>/tests/integration-tests/vnet/*.tftest.hcl`

Before creating files, ensure these folders exist (create if missing):

- `<terraform_root>/tests/integration-tests/`
- `<terraform_root>/tests/integration-tests/vnet/`

## Preconditions (integration)

Your generated tests should assume CI provides:

- Azure authentication (e.g., OIDC) for the AzureRM provider
- A subscription and allowed region(s)

Your tests must be compatible with Terraform 1.7+.

## Integration test strategy options

Terraform’s test framework can assert on:

- resource values in the configuration after apply, and
- values derived from expressions/locals, and
- (recommended) `data` sources that query Azure.

Because Terraform tests live alongside the configuration under test, there are two common strategies. Pick the simplest that works for the Terraform folder you are scanning.

### Strategy A (preferred): Assert via `data` sources + outputs

Use when the Terraform root already contains (or can tolerate under `tests/`) a small “test harness” module that:

- calls the production module/root
- reads back Azure state using `data "azurerm_virtual_network"` / `data "azurerm_subnet"`
- exports outputs for assertions

This gives robust validation even when VNets are created inside modules.

### Strategy B: Assert on direct resources

Use when VNets are created directly as `azurerm_virtual_network` and `azurerm_subnet` in the Terraform root being tested.

## What to validate in integration tests

Choose from the list below based on what the Terraform folder exposes.

### VNet validations

- VNet exists in Azure (by ID from output, or by name+RG)
- Address spaces in Azure match expected values
- Tags in Azure contain required keys
- Location matches expected policy

### Subnet validations

- Subnets exist (count and names)
- Each subnet CIDR matches expected
- Network policies match expected (private endpoint / private link service)

### Peering validations (if present)

- Peering connections exist (both directions, if required)
- Peering flags match expected values

## Test authoring guidance (tftest.hcl)

- Use `run "apply" { command = apply }` for deployment.
- Prefer _explicit variables_ in the test file so the integration test can create unique resource names.
  - CI should pass a unique `test_run_id` (or similar) so naming does not collide.
- Use `assert { ... }` checks against either:
  - `data` sources (recommended), or
  - outputs produced by the configuration under test.

## Diagnostics requirement (must follow)

- Keep a single `run "apply" { command = apply }` to avoid redeploying for each check.
- Every `assert` MUST have a specific `error_message` that identifies the failing resource and property.
- Prefer multiple small asserts (each with its own message) over one compound boolean.
- CI visibility recommendation: use JUnit output so failures list cleanly by message/run:
  - `terraform test -junit-xml=tests/test-results.xml`

### Cleanup / lifecycle

Avoid leaving resources behind.

When possible:

- Keep integration tests in a dedicated, disposable resource group.
- Ensure the Terraform configuration under test supports full destroy.

(Note: some organizations prefer a separate cleanup job rather than test-driven destroy; follow the repo’s CI conventions.)

## Minimum output contract

When finished, the generated integration test set must include at least one `.tftest.hcl` file that:

- contains at least one `run` block with `command = apply`
- validates at least one VNet-related property against Azure (directly or via data sources)
- documents required environment variables / credentials at top of file as comments
