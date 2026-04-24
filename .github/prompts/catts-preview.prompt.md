---
description: "Preview CATTS output for a Terraform root: show which resource categories are detected and exactly which unit/integration tests would be generated (no file writes)."
argument-hint: "Terraform root folder (e.g., AI-Landing-Zones/terraform)"
agent: "agent"
---

Preview CATTS generation for this Terraform root folder:

- Terraform root: ${input}

Requirements:

- Preview/dry-run only: do not modify any files.
- Do not run Terraform commands.

Use the **B model (top-level orchestration)**:

1. Invoke the CATTS helper agent `.github/agents/helpers/get-resource-types.agent.md` with the Terraform root.
2. Parse the helper output labels:
   - `- Resource types: ...`
   - `- CATTS categories: ...`
3. For each inferred category, determine will-generate vs skipped by checking presence of the required agent + instruction files under `.github/agents` and `.github/instructions`.

Output must be nicely formatted and include:

- detected Terraform resource types
- inferred CATTS categories
- per category: which unit tests and which integration tests (Terraform vs Python) would be generated
- the planned output filenames for each test type (explicit file names)
- which items are skipped (with reasons)
