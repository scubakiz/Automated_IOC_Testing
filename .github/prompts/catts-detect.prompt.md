---
description: "Detect Terraform resource types and CATTS categories present in a Terraform root (read-only)."
argument-hint: "Terraform root folder (e.g., AI-Landing-Zones/terraform)"
agent: "agent"
---

Detect Terraform resource types for this Terraform root folder:

- Terraform root: ${input}

Requirements:

- Read-only: do not run Terraform commands and do not modify files.
- Prefer scanning `.tf` files to list:
  - resource block types
  - data source types
  - module blocks
- Return a compact summary plus JSON if available.

If the CATTS helper agent `get-resource-types` is available, invoke it with the Terraform root path.
Otherwise, explain what file to copy into `.github/agents/helpers/` to enable it.
