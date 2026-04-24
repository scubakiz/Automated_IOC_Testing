---
description: "Remove CATTS-generated tests under a Terraform root (unit-tests + integration-tests) so you can re-run generation."
argument-hint: "Terraform root folder (e.g., AI-Landing-Zones/terraform)"
agent: "agent"
---

Clean CATTS-generated tests for this Terraform root folder:

- Terraform root: ${input}

Delete (if present):

- `${input}/tests/unit-tests/`
- `${input}/tests/integration-tests/`

Do not delete anything else.
If the CATTS cleanup agent is available, invoke it with the Terraform root path.
Otherwise, explain how to make it discoverable (copy from `CATTS/.github/agents` to `.github/agents`).
