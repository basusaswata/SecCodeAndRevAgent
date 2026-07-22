# SecureCodeGenRevAgent (SCGRA)

Secure coding **rules** and a **reviewer agent** for AI-assisted development.

SCGRA steers code generation away from common weaknesses (including a CWE
catalog) and supports structured security reviews that emit **SARIF 2.1.0**.

```
SecureCodeGenRevAgent/
├── cursor/
│   ├── rules/scgra-*.mdc          # Cursor IDE rules
│   └── agents/scgra-reviewer.md   # Cursor security-review agent
├── github/
│   ├── instructions/scgra-*.instructions.md  # GitHub Copilot instructions
│   └── prompts/scgra-reviewer.md             # Copilot / PR review prompt
├── install-to-workspace.sh
└── README.md
```

| Prefix | Severity (in SARIF) | Purpose |
|--------|---------------------|---------|
| `scgra-1-*` | `error` | High-priority (e.g. hardcoded credentials, weak crypto) |
| `scgra-0-*` | `warning` | Broad secure-coding topics + CWE catalog |

Notable rule: **`scgra-0-cwe-prevention`** — CWE list used for both generation
guidance and review detection signals.

---

## Install

### Option A — Install into a single project (recommended)

From this pack’s directory, copy into your app repo:

```bash
APP=/path/to/your-app
SRC="$(pwd)"   # SecureCodeGenRevAgent root

mkdir -p "$APP/.cursor/rules" "$APP/.cursor/agents" \
         "$APP/.github/instructions" "$APP/.github/prompts"

cp -R "$SRC/cursor/rules/"*           "$APP/.cursor/rules/"
cp -R "$SRC/cursor/agents/"*          "$APP/.cursor/agents/"
cp -R "$SRC/github/instructions/"*    "$APP/.github/instructions/"
cp -R "$SRC/github/prompts/"*         "$APP/.github/prompts/"
```

Commit the `.cursor/` and `.github/` files so the whole team gets the same rules.

### Option B — Install into an Eclipse / multi-root workspace

```bash
chmod +x ./install-to-workspace.sh
./install-to-workspace.sh /Users/saswatabasu/Saswata/eclipse-workspace
```

This creates:

- `<workspace>/.cursor/rules` + `agents`
- `<workspace>/.github/instructions` + `prompts`

Override the destination:

```bash
./install-to-workspace.sh /path/to/other-workspace
```

### Verify

```bash
ls .cursor/rules/scgra-*.mdc | head
ls .github/instructions/scgra-*.instructions.md | head
ls .cursor/agents/scgra-reviewer.md
ls .github/prompts/scgra-reviewer.md
```

---

## Use within the IDE (Cursor)

### 1. Secure code generation (automatic)

Once `.cursor/rules/scgra-*.mdc` are present:

- Rules with `alwaysApply: true` (e.g. credentials, CWE catalog) apply to every chat.
- Rules with `globs:` apply when you edit matching files.

Ask Cursor to implement features as usual. The model should avoid patterns banned
by the rules (SQL concat, hardcoded secrets, mass assignment, etc.).

Example prompts:

- “Add a login endpoint that authenticates against the users table.”
- “Follow the SCGRA / CWE prevention rules; do not introduce injection or IDOR.”

### 2. Security review / SARIF (agent)

Use the **`scgra-reviewer`** agent when you want a scan, not normal coding help.

In Cursor Agent chat, ask explicitly, for example:

```text
Run the SecureCodeGen (scgra) security review on this repository.
Emit SARIF and summarize confirmed findings.
```

Or invoke the custom agent if your Cursor build lists agents:

```text
Use the scgra-reviewer agent on this repo.
```

The agent will:

1. Detect languages in the repo  
2. Load applicable `scgra-*.mdc` rules (including the CWE catalog)  
3. Search for violations (skipping rule dirs, `node_modules/`, `target/`, etc.)  
4. Triage: `confirmed` / `false-positive` / `needs-human`  
5. Write **only** `scgra-findings-<UTC_TIMESTAMP>.sarif` at the repo root  
6. Return a markdown summary (counts, top files, FP notes)

Open the SARIF in your IDE or upload it to GitHub code scanning.

### 3. Ad-hoc review without the agent

You can still ask in chat:

```text
Review the changed files against .cursor/rules/scgra-*.mdc and
scgra-0-cwe-prevention. List CWE IDs, file:line, and fixes.
```

---

## Use when reviewing PRs on GitHub

SCGRA’s GitHub pack targets **GitHub Copilot** (coding agent / code review) via
[custom instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
and [prompt files](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot).

### 1. One-time setup in the repo

Ensure these are **committed on the default branch** (and on the PR branch if
instructions are resolved from the PR head):

```text
.github/instructions/scgra-*.instructions.md
.github/prompts/scgra-reviewer.md
```

`applyTo` in each instruction file controls which paths Copilot attaches them to
(e.g. `**/*` for the CWE catalog, language globs for topic rules).

### 2. PR review with Copilot (interactive)

On a pull request:

1. Open the **Files changed** tab (or the Copilot PR review UI).  
2. Ask Copilot to review against SCGRA, for example:

```text
Review this PR using the SecureCodeGen (SCGRA) instructions under
.github/instructions/. Flag any scgra rule or CWE catalog violations.
For each finding: rule_id or CWE, file, line, why, and a concrete fix.
Do not suggest exploit payloads.
```

Or point at the prompt file:

```text
Follow .github/prompts/scgra-reviewer.md for this PR diff.
Produce a triage summary (confirmed / needs-human / false-positive).
If you can write files, emit scgra-findings-<UTC>.sarif at the repo root.
```

3. Require authors to address **confirmed** items (especially `scgra-1-*`)
   before merge.

### 3. PR review checklist for humans

Use this when doing a manual GitHub review:

- [ ] No new hardcoded secrets (`scgra-1-hardcoded-credentials`)  
- [ ] No SQL/command/LDAP string concatenation (`scgra-0-input-validation-injection`, CWE-89/78)  
- [ ] Authn/authz on new endpoints; no IDOR/BOLA (`scgra-0-authorization-access-control`)  
- [ ] No mass assignment of privileged fields  
- [ ] Sensitive data not logged or returned unnecessarily  
- [ ] Dependencies / CI changes don’t weaken supply-chain controls  

### 4. Optional: attach SARIF to the PR

After an IDE or agent review:

1. Commit or upload `scgra-findings-*.sarif`, **or**  
2. Use GitHub code scanning SARIF upload (Actions / API) so findings appear on
   the PR Security tab.

Example Actions snippet (optional):

```yaml
- name: Upload SCGRA SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: scgra-findings-YYYYMMDDTHHMMSSZ.sarif
```

---

## Rule inventory (high level)

| Area | Examples |
|------|----------|
| Secrets / crypto | `scgra-1-hardcoded-credentials`, `scgra-1-crypto-algorithms`, `scgra-1-digital-certificates` |
| Injection / input | `scgra-0-input-validation-injection`, `scgra-0-xml-and-serialization` |
| Authn / authz / session | `scgra-0-authentication-mfa`, `scgra-0-authorization-access-control`, `scgra-0-session-management-and-cookies` |
| API / web | `scgra-0-api-web-services`, `scgra-0-client-side-web-security` |
| Data / privacy / logging | `scgra-0-data-storage`, `scgra-0-privacy-data-protection`, `scgra-0-logging` |
| Cloud / DevOps | `scgra-0-iac-security`, `scgra-0-devops-ci-cd-containers`, `scgra-0-cloud-orchestration-kubernetes`, `scgra-0-supply-chain-security` |
| CWE catalog | `scgra-0-cwe-prevention` |

Full list: see `cursor/rules/` and `github/instructions/`.

---

## Design notes

- **Generation + review** — same rule bodies guide both writing and auditing.  
- **No weaponization** — reviewer/prompt focus on defensive findings and fixes.  
- **Read-only review** — `scgra-reviewer` only writes the SARIF findings file.  
- **Skip noise** — rule packs, vendored trees (`node_modules/`, `target/`, …) are
  excluded from findings.

---

## Quick start

```bash
# 1. Install into your app
./install-to-workspace.sh /path/to/your-app   # or use Option A copy commands

# 2. In Cursor: implement features (rules apply automatically)
# 3. In Cursor: “Run scgra-reviewer on this repo”
# 4. On GitHub PR: ask Copilot to review using .github/instructions (SCGRA)
```
