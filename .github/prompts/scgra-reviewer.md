---
name: scgra-reviewer
description: Review this PR or repository using AISecCore skills; emit SARIF when possible.
---

# GitHub Copilot adapter → AISecCore

Follow:

1. **`AISecCore/prompts/scgra-reviewer.md`** (short prompt)
2. **`AISecCore/agents/scgra-reviewer.md`** (full procedure)
3. Skills in **`AISecCore/skills/scgra-*.md`**

Produce a triage summary (`confirmed` / `needs-human` / `false-positive`).
If you can write files, emit `scgra-findings-<UTC>.sarif` at the repo root only.
