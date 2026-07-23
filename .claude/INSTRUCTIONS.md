# AISecCore (Claude Code adapter)

This project uses the shared **AISecCore** security pack.

## Skills

When writing or editing code, read and obey applicable skills under:

`AISecCore/skills/scgra-*.md`

Always apply high-priority skills (`scgra-1-*`) and the CWE catalog
(`scgra-0-cwe-prevention.md`). Match other skills by language / path as described
in each file’s frontmatter (`globs` / `applyTo`).

## Security review

When the user asks for a security review, SARIF, or SCGRA / AISecCore compliance check:

1. Follow `AISecCore/agents/scgra-reviewer.md`
2. Optionally use `AISecCore/prompts/scgra-reviewer.md`
3. Write only `scgra-findings-<UTC_TIMESTAMP>.sarif` at the repository root

## Constraints

- Defensive fixes only — no exploit code or attack payloads.
- Do not treat example snippets inside `AISecCore/` as application findings.
- Prefer existing project patterns when applying remediations.
