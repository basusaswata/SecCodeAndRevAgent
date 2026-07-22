---
applyTo: '**/*'
description: CWE catalog for secure code generation and security review — avoid and detect listed weaknesses
version: 1.0.0
tags: [cwe, secure-coding, review]
---

rule_id: scgra-0-cwe-prevention

# CWE Prevention & Review Catalog

Use this catalog in **two modes**:

1. **Code generation** — never introduce any weakness in the list below. Prefer
   secure APIs and patterns that make these CWEs impossible or unlikely.
2. **Code review** — search the target code for evidence of these CWEs. Cite the
   CWE ID, file, line, why it matches, and a concrete fix. Classify each hit as
   `confirmed`, `false-positive`, or `needs-human`.

Do not invent CWE IDs. Only use IDs from this catalog (or parent/child of these
when a more specific mapping is clearly better — state the parent you started from).

---

## How to apply (generation)

- Treat all external input (HTTP, files, queues, env from untrusted deploy, CLI
  args, DB rows from other tenants) as **untrusted**.
- Prefer: parameterized queries, safe HTML encoders, allow-lists, structured
  command APIs (no shell), constant-time compares for secrets, modern crypto
  libraries, least privilege.
- Never: string-concat SQL/commands/LDAP, `innerHTML` with raw input, hardcoded
  secrets, MD5/SHA1 for passwords, disabled TLS verify in production paths.

## How to apply (review)

For each CWE below, look for the **Detection signals**. When found:

- Record: `CWE-ID`, path, line, short snippet, why it is a match, remediation.
- Prefer actionable findings over theoretical ones.
- Skip vendored/generated paths (`node_modules/`, `vendor/`, `.venv/`, `dist/`,
  `build/`, `target/`, and repo `.gitignore` excludes).

---

## CWE catalog

### Injection & interpretation

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-89** | SQL Injection | Parameterized queries / ORM bind params only; never concatenate user data into SQL | `execute(f"…{var}")`, string `+` into SQL, raw `Statement`, `$query = "…$user"` |
| **CWE-90** | LDAP Injection | Escape DN/filter; allow-list; no raw concat into filters | LDAP filter built with string concat from request input |
| **CWE-78** | OS Command Injection | No shell; `ProcessBuilder` / `subprocess` list form; allow-list commands | `shell=True`, `Runtime.exec(string)`, `os.system`, backticks with user input |
| **CWE-77** | Command Injection (generic) | Same as CWE-78; prefer library APIs over spawning processes | Process spawn with interpolated untrusted strings |
| **CWE-94** | Code Injection | Never `eval`/`exec` on untrusted data; no dynamic code from users | `eval(`, `exec(`, `Function(`, `new Function`, `compile(` on input |
| **CWE-95** | Eval Injection | Ban `eval` on request/file content | Same as CWE-94 language-specific eval APIs |
| **CWE-917** | Expression Language Injection | Disable or sandbox EL; never feed user strings into EL engines | User input into SpEL, OGNL, Freemarker/Velocity without sandbox |
| **CWE-643** | XPath Injection | Parameterized XPath / compiled queries with bound vars | XPath string built from user input |
| **CWE-91** | XML Injection | Use safe XML APIs; validate/encode before embedding | Raw user XML concatenated into documents/queries |
| **CWE-74** | Injection (generic) | Separate code from data at every interpreter boundary | Untrusted data reaches any interpreter/parser as code |

### XSS & web client

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-79** | Cross-site Scripting | Context-aware encoding; framework auto-escape; CSP | `innerHTML`, `dangerouslySetInnerHTML`, unescaped templates, `document.write` with input |
| **CWE-80** | Basic XSS | Same as CWE-79; never reflect raw input into HTML | Reflected request params in HTML without encode |
| **CWE-83** | XSS via Script spoof | Encode/CSP; validate URLs (`javascript:`) | User-controlled `href`/`src` without scheme allow-list |

### Path, file, XXE, SSRF

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-22** | Path Traversal | Resolve under a fixed root; reject `..`; server-generated names | `open(user_path)`, `../` not normalized, zip-slip style extracts |
| **CWE-23** | Relative Path Traversal | Canonicalize then prefix-check against allow-listed base dir | Relative paths joined without canonical base check |
| **CWE-73** | External Control of File Name/Path | Do not let clients choose absolute paths | Filename/path taken from request and used for I/O |
| **CWE-434** | Unrestricted Upload | Magic-byte type check, size cap, safe extension allow-list, store outside web root | Upload saved with client filename/extension; no type/size checks |
| **CWE-611** | XXE | Disable external entities/DTD on XML parsers | Default XML parser; `setFeature` not disabling external entities |
| **CWE-918** | SSRF | Allow-list outbound hosts/schemes; block link-local/metadata IPs | HTTP client fetches URL from user input without validation |

### Authn, authz, session, credentials

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-287** | Improper Authentication | Strong auth at trust boundaries; fail closed | Missing auth checks on sensitive routes |
| **CWE-306** | Missing Authentication for Critical Function | Require auth on all privileged operations | Admin/delete/pay endpoints without auth middleware |
| **CWE-862** | Missing Authorization | Enforce object-level and function-level authz | IDOR: resource ID from client used without ownership check |
| **CWE-863** | Incorrect Authorization | Deny by default; test negative cases | Authz present but wrong role/condition |
| **CWE-269** | Improper Privilege Management | Least privilege; no unnecessary elevation | Running as root/admin without need; overly broad roles |
| **CWE-384** | Session Fixation | Rotate session ID on login | Session ID reused across authentication |
| **CWE-613** | Insufficient Session Expiration | Idle + absolute timeouts; invalidate on logout | No session timeout / logout does not invalidate server session |
| **CWE-798** | Use of Hard-coded Credentials | Secrets from vault/env/secret manager only | Passwords, API keys, tokens in source |
| **CWE-259** | Use of Hard-coded Password | Same as CWE-798 | Literal password strings in code/config committed to VCS |
| **CWE-521** | Weak Password Requirements | Enforce length/complexity/breach checks as policy requires | Accepting trivial passwords; no policy enforcement |
| **CWE-307** | Improper Restriction of Excessive Auth Attempts | Rate-limit / lockout / backoff on auth endpoints | Login with no throttling |
| **CWE-352** | CSRF | Anti-CSRF tokens or SameSite + careful CORS for cookie auth | State-changing POST without CSRF defense |

### Crypto & randomness

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-327** | Broken/Risky Crypto Algorithm | Use modern vetted libs (AES-GCM, ChaCha20-Poly1305); no homegrown crypto | DES, RC4, ECB mode, custom ciphers |
| **CWE-328** | Weak Hash | Passwords: Argon2/bcrypt/scrypt; integrity: SHA-256+ | MD5/SHA1 for passwords or security decisions |
| **CWE-330** | Insufficiently Random Values | CSPRNG only for tokens/keys/IDs with security meaning | `Math.random`, `random` without secrets module for tokens |
| **CWE-331** | Insufficient Entropy | Sufficient key/token length; CSPRNG | Short predictable tokens |
| **CWE-338** | Weak PRNG | Same as CWE-330 | Non-crypto PRNG for security-sensitive values |
| **CWE-326** | Inadequate Encryption Strength | Meet current key-size guidance (e.g. RSA ≥ 2048, AES-128+) | 512-bit RSA, export-grade ciphers |
| **CWE-311** | Missing Encryption of Sensitive Data | TLS in transit; encrypt sensitive fields at rest when required | Secrets/PII in plaintext stores or cleartext protocols |
| **CWE-319** | Cleartext Transmission of Sensitive Info | HTTPS/TLS; no credentials over HTTP | HTTP URLs for login/API keys; disable TLS verify |
| **CWE-295** | Improper Certificate Validation | Never disable verify in production | `verify=False`, `InsecureSkipVerify`, trust-all TrustManager |
| **CWE-347** | Improper Verification of Cryptographic Signature | Verify signatures before trust; use vetted JWT/libs correctly | Accepting JWT without verify; `alg=none` |

### Memory & unsafe native

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-119** | Buffer Overflow (bound) | Safe languages or bounds-checked APIs; no unbounded copies | `strcpy`, `gets`, unbounded `sprintf`, raw pointer writes |
| **CWE-120** | Classic Buffer Overflow | Prefer `strncpy`-style safe APIs with explicit sizes (still validate) | Fixed buffer + unchecked length input |
| **CWE-125** | Out-of-bounds Read | Check lengths before read | Array/slice index without bounds check |
| **CWE-787** | Out-of-bounds Write | Same; use safe containers | Write past allocated buffer |
| **CWE-416** | Use After Free | Ownership discipline; avoid manual free when possible | Free/delete then use pointer |
| **CWE-476** | NULL Pointer Dereference | Check pointers/Option/Maybe before use | Deref without null check |
| **CWE-190** | Integer Overflow/Wraparound | Checked arithmetic; validate sizes before alloc | Size calc without overflow checks feeding alloc/copy |

### Deserialization, redirect, info leak, config

| CWE | Name | Generation (do) | Detection signals |
|-----|------|-----------------|-------------------|
| **CWE-502** | Deserialization of Untrusted Data | Avoid native deserialize on untrusted input; allow-list types; prefer JSON with schema | `pickle.loads`, Java `ObjectInputStream` on user data, `yaml.load` (unsafe) |
| **CWE-601** | Open Redirect | Allow-list redirect targets; relative paths only | `redirect(request.args['url'])` without allow-list |
| **CWE-209** | Error Message Information Exposure | Generic client errors; detail only in server logs | Stack traces / SQL errors returned to clients |
| **CWE-200** | Exposure of Sensitive Information | Minimize data returned; scrub logs | PII/secrets in responses or logs |
| **CWE-532** | Insertion of Sensitive Info into Log File | Redact secrets/tokens/passwords in logs | Logging Authorization headers, passwords, full cards |
| **CWE-117** | Log Injection | Encode/sanitize CR/LF in logged untrusted data | User input written raw into logs |
| **CWE-16** | Configuration | Secure defaults; no debug in prod | `debug=True`, directory listing on, default creds |
| **CWE-1188** | Insecure Default Initialization | Explicit secure config; fail closed | Framework defaults left insecure |
| **CWE-250** | Execution with Unnecessary Privileges | Drop privileges; container non-root | Containers/processes as root without need |
| **CWE-276** | Incorrect Default Permissions | Restrictive file modes for secrets/keys | World-readable key material (`0666`/`0777` on secrets) |
| **CWE-362** | Race Condition | Atomic ops / locking for shared mutable state | TOCTOU on files/auth checks |
| **CWE-367** | TOCTOU | Open-then-check via safe APIs; avoid check-then-act on paths | `exists` then `open` on attacker-controlled path |
| **CWE-400** | Uncontrolled Resource Consumption | Timeouts, size limits, rate limits | Unbounded reads/uploads/regex (ReDoS) |
| **CWE-770** | Allocation without Limits | Cap request body, collections, uploads | No max size on buffers/uploads |
| **CWE-1333** | ReDoS | Avoid evil regex on user input; use safe parsers | Complex nested quantifier regex on untrusted strings |
| **CWE-668** | Exposure of Resource to Wrong Sphere | Tenant isolation; no shared mutable caches of secrets | Cross-tenant data access |
| **CWE-915** | Mass Assignment | Allow-list bindable fields | Binding entire request body into privileged model fields |
| **CWE-639** | Authorization Bypass Through User-Controlled Key | Server-side lookup by session identity, not client-supplied owner id | Using client `userId` for access without verify |
| **CWE-284** | Improper Access Control | Deny-by-default access policy | Missing access checks on sensitive operations |

---

## Review output expectations

When reviewing, prefer structured findings:

```text
CWE-89 | confirmed | app/dao.py:42
Why: SQL built with f-string from request parameter `user_id`
Fix: Use parameterized execute("… WHERE id = ?", [user_id])
```

When generating code, if a request would require an insecure pattern from this
list, refuse that pattern and provide a secure alternative instead.
