---
applyTo: "**/*"
description: Load AISecCore skills for secure code generation and Copilot review
---

# AISecCore (GitHub Copilot adapter)

This repository uses the shared **AISecCore** pack. Treat the files below as authoritative.

## Skills

Follow all applicable skills in:

`AISecCore/skills/scgra-*.md`

Especially:

- `scgra-1-hardcoded-credentials`, `scgra-1-crypto-algorithms`, `scgra-1-digital-certificates`
- `scgra-0-cwe-prevention`
- Topic skills matching the files in the PR (injection, authz, IaC, etc.)

## Review / PR

When asked to security-review a PR or emit SARIF, follow:

`AISecCore/agents/scgra-reviewer.md`

Or the short prompt:

`AISecCore/prompts/scgra-reviewer.md`

For each finding: skill `id` / `rule_id`, file, line, why, and a concrete defensive fix.
Do not suggest exploit payloads.

## Constraints

Skill bodies under `AISecCore/` contain examples for teaching; do not report those paths as vulnerabilities in app code.
