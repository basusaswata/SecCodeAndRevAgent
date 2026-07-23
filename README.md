# SecureCodeGenRevAgent (SCGRA) + AISecCore

Secure coding **skills**, **agents**, and **prompts** for AI-assisted development —
with thin adapters for Cursor, GitHub Copilot, and Claude Code.

```
SecCodeAndRevAgent/
├── AISecCore/                         # ← single source of truth (all Markdown)
│   ├── skills/scgra-*.md              # security guidance
│   ├── agents/scgra-reviewer.md       # full review procedure
│   └── prompts/scgra-reviewer.md      # short review prompt
├── .cursor/                           # Cursor adapter (single rule + agent pointer)
├── .github/                           # Copilot adapter (single instruction + prompt)
├── .claude/                           # Claude Code adapter (single INSTRUCTIONS.md)
├── install-to-workspace.sh
└── README.md
```

**Do not duplicate skill bodies** into `.cursor` / `.github` / `.claude`. Those folders
only instruct the host to load `AISecCore/`.

| Prefix | SARIF level | Purpose |
|--------|-------------|---------|
| `scgra-1-*` | `error` | High priority (credentials, weak crypto, certificates) |
| `scgra-0-*` | `warning` | Broad secure-coding + CWE catalog |

Notable skill: `AISecCore/skills/scgra-0-cwe-prevention.md`.

---

## Install into an app repo

```bash
cd /path/to/SecCodeAndRevAgent
./install-to-workspace.sh /path/to/your-app
```

This creates/updates:

```text
your-app/
├── AISecCore/                 # skills, agents, prompts
├── .cursor/rules/aisec-core.mdc
├── .cursor/agents/scgra-reviewer.md
├── .github/instructions/aisec-core.instructions.md
├── .github/prompts/scgra-reviewer.md
└── .claude/INSTRUCTIONS.md
```

Commit `AISecCore/` and the adapter folders so the whole team shares them.

### Verify

```bash
ls AISecCore/skills/scgra-*.md | head
ls .cursor/rules/aisec-core.mdc
ls .github/instructions/aisec-core.instructions.md
ls .claude/INSTRUCTIONS.md
```

---

## Use in Cursor

1. **Secure generation** — `.cursor/rules/aisec-core.mdc` (`alwaysApply`) tells the
   model to follow `AISecCore/skills/*.md`.
2. **Security review** — ask for `scgra-reviewer` / AISecCore review; the agent adapter
   runs `AISecCore/agents/scgra-reviewer.md` and writes
   `scgra-findings-<UTC>.sarif`.

```text
Run the AISecCore / scgra-reviewer security review on this repository.
Emit SARIF and summarize confirmed findings.
```

---

## Use on GitHub (Copilot)

Committed adapters:

```text
.github/instructions/aisec-core.instructions.md
.github/prompts/scgra-reviewer.md
```

On a PR, ask Copilot to follow those files / `AISecCore/`. Require authors to fix
**confirmed** `scgra-1-*` items before merge.

Optional SARIF upload:

```yaml
- name: Upload SCGRA SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: scgra-findings-YYYYMMDDTHHMMSSZ.sarif
```

---

## Use with Claude Code

`.claude/INSTRUCTIONS.md` points Claude at `AISecCore/skills` for generation and
`AISecCore/agents/scgra-reviewer.md` for reviews.

---

## Skill inventory (high level)

| Area | Examples |
|------|----------|
| Secrets / crypto | `scgra-1-hardcoded-credentials`, `scgra-1-crypto-algorithms`, `scgra-1-digital-certificates` |
| Injection / input | `scgra-0-input-validation-injection`, `scgra-0-xml-and-serialization` |
| Authn / authz / session | `scgra-0-authentication-mfa`, `scgra-0-authorization-access-control`, `scgra-0-session-management-and-cookies` |
| API / web | `scgra-0-api-web-services`, `scgra-0-client-side-web-security` |
| Data / privacy / logging | `scgra-0-data-storage`, `scgra-0-privacy-data-protection`, `scgra-0-logging` |
| Cloud / DevOps | `scgra-0-iac-security`, `scgra-0-devops-ci-cd-containers`, `scgra-0-cloud-orchestration-kubernetes`, `scgra-0-supply-chain-security` |
| CWE catalog | `scgra-0-cwe-prevention` |

Full list: `AISecCore/skills/`.

---

## Design notes

- **One core, many hosts** — AISecCore is canonical Markdown; IDE folders are adapters.
- **Generation + review** — same skills guide writing and auditing.
- **No weaponization** — defensive findings and fixes only.
- **Read-only review** — reviewer only writes the SARIF findings file.
- **Skip noise** — exclude `AISecCore/` and adapter dirs from findings.

---

## Quick start

```bash
./install-to-workspace.sh /path/to/your-app
# In Cursor / Claude: implement features (skills apply via adapter)
# Ask: “Run scgra-reviewer / AISecCore review on this repo”
# On GitHub PR: ask Copilot to use .github + AISecCore
```
