# AISecCore

Canonical **skills**, **agents**, and **prompts** for SecureCodeGenRevAgent (SCGRA).

IDE-specific folders (`.cursor`, `.github`, `.claude`) contain **thin adapters** that
point here — do not duplicate skill bodies outside this directory.

```
AISecCore/
├── skills/     # Security guidance (scgra-*.md) — generation + review
├── agents/     # Full reviewer procedure (scgra-reviewer.md)
└── prompts/    # Short review prompts that invoke the agent
```

| Prefix | Severity | Purpose |
|--------|----------|---------|
| `scgra-1-*` | error | High priority (credentials, crypto, certificates) |
| `scgra-0-*` | warning | Broad secure-coding + CWE catalog |

Notable skill: `skills/scgra-0-cwe-prevention.md`.

When reviewing, follow `agents/scgra-reviewer.md` and load all applicable `skills/scgra-*.md`.
