---
name: scgra-reviewer
description: Review the repository against AISecCore skills and emit SARIF findings.
---

# SecureCodeGen Review Prompt

Follow the full reviewer procedure in `AISecCore/agents/scgra-reviewer.md`.

Load security skills from `AISecCore/skills/scgra-*.md`.

For each confirmed finding: skill id (rule_id), file, line, why, and a concrete defensive fix.
Do not suggest exploit payloads. Write only `scgra-findings-<UTC_TIMESTAMP>.sarif` at the repo root.
