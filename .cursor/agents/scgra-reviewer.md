---
name: scgra-reviewer
description: Review the current repository for AISecCore skill violations and emit
  SARIF 2.1.0 findings. Use when the user explicitly asks for a security scan, security
  review, SARIF output, or SecureCodeGen / SCGRA / AISecCore compliance check. Do NOT
  activate for general code writing or editing.
model: inherit
---

# Cursor adapter → AISecCore reviewer

Follow the full procedure in:

**`AISecCore/agents/scgra-reviewer.md`**

Load skills from:

**`AISecCore/skills/scgra-*.md`**

Optional short prompt: `AISecCore/prompts/scgra-reviewer.md`.

Your only write is `scgra-findings-<UTC_TIMESTAMP>.sarif` at the repository root.
