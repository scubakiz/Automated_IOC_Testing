---
description: "Generate CATTS tests for a Terraform root: detect resource types, then generate supported unit/integration tests (skipping unsupported types)."
argument-hint: "Terraform root folder (e.g., AI-Landing-Zones/terraform)"
agent: "agent"
---

Generate CATTS tests for this Terraform root folder:

- Terraform root: ${input}

Requirements:

- Do not run Terraform commands.
- Do not modify infrastructure code.
- Only generate tests under `${input}/tests/unit-tests/**` and `${input}/tests/integration-tests/**`.

Switch to the **orchestrator** agent mode and follow all steps in `.github/agents/orchestrator.agent.md`:

1. Scan every `*.tf` file in the Terraform root (skip `.terraform/`), detect resource types, infer CATTS categories.
2. Read the per-category instruction files and generate all unit + integration test files directly using the edit tool.
3. Verify files were created and list them.

Output must include:

- detected Terraform resource types
- inferred CATTS categories
- which instruction files were read per category
- verification: list of all generated files (paths relative to Terraform root), or explicit failure if none created
