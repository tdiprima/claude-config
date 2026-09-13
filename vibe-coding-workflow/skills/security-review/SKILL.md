---
name: security-review
description: Review-only, attack-oriented security review of a code change or codebase using OWASP-style source-to-sink tracing. Finds injection, authn/authz and IDOR flaws, secrets, unsafe subprocess use, path traversal, SSRF, crypto misuse, and supply-chain risk, ranked by exploitability and impact. Never edits code. Not for general bugs (use code-review) or for vetting untrusted third-party code before running it.
metadata:
  short-description: OWASP-style attack-oriented review
---

# Security Review

Perform a security review of this change as an attacker would approach it. Assume every
input may be malicious and the runtime environment may be hostile.

## Scope

If the user names a target (file, directory, glob, commit, branch, or PR), review that.
Otherwise use the first one that applies:

1. Staged changes: `git diff --cached`
2. Unstaged changes: `git diff`
3. Branch changes: `git diff $(git merge-base HEAD <default-branch>)`
4. Otherwise ask the user what to review. Do not guess.

A vulnerability often spans files outside the diff. Follow data flow into unchanged code when
needed. If the repo has a `.codegraph` folder or codegraph tools, use them to trace callers
and data flow. State the exact target at the top of the report.

## Rules

- Review only. Do not edit, create, or delete files. Do not commit. Fixing is a separate step.
- Do not run exploits against live systems, external hosts, or production data. Reason from
  the code. Local, read-only commands (for example `git log`, reading config) are fine.
- If a secret scanner or dependency audit tool is already installed and configured, you may
  run it and report the result. Do not install anything.
- Never print a discovered secret value. Report its location and type only.
- Report only issues with a plausible attack path. Mark theory-only issues as such.
- If a category is clean, say so. Do not invent findings to fill the report.

## Method

1. Map the attack surface: list every entry point for untrusted data (HTTP routes, CLI
   arguments, environment, files, uploads, queues, webhooks, third-party API responses, LLM
   output).
2. Map the sensitive sinks: SQL/NoSQL queries, shell and subprocess calls, file system paths,
   outbound HTTP requests, HTML rendering, deserialization, `eval`-style execution, auth
   decisions, logging.
3. Trace untrusted input from each entry point to each sink. Note where it is validated,
   encoded, or authorized, and where it is not.
4. Check each category below against what you traced.

## Check for

- Authentication flaws: missing auth on endpoints, weak session handling, JWTs not checked for
  expiry, issuer, and audience.
- Authorization and IDOR: missing ownership or role checks, user-controlled IDs used directly
  in queries, privilege escalation between roles.
- Injection: SQL/NoSQL, OS command, LDAP, template, header, and log injection.
- XSS: `innerHTML` and similar sinks, unescaped template output, unsafe markdown rendering.
- SSRF: user-controlled URLs fetched by the server, including redirects and internal addresses.
- Path traversal and insecure file handling: user-controlled paths, unsafe archive extraction,
  world-writable files, predictable temp files.
- Unsafe deserialization: `pickle`, `yaml.load`, Java/PHP object deserialization, `eval`.
- Unsafe subprocess or shell use: `shell=True`, string-built commands, unquoted variables.
- Secrets and credentials: hardcoded keys, tokens, passwords, connection strings, secrets in
  logs, config files, test fixtures, or client-side code.
- Cryptographic misuse: MD5/SHA-1 for passwords, homemade crypto, ECB mode, disabled TLS
  verification, static IVs or salts.
- Insecure randomness: `random`/`Math.random` for tokens, IDs, or secrets.
- Sensitive data leakage: PII or tokens in logs, stack traces returned to clients, verbose
  error messages, overly broad API responses.
- Excessive permissions: services running as root, broad file modes, wildcard IAM or CORS,
  over-privileged DB users or API keys.
- Race conditions and TOCTOU: check-then-use on files, double-spend on counters or balances.
- Dependency and supply-chain risk: known-vulnerable versions, unpinned versions, typosquatted
  or unmaintained packages, `curl | bash` installs.
- Insecure defaults: debug mode on, permissive CORS, missing security headers, auth disabled
  by default, fail-open error handling.
- Missing input validation: types, lengths, ranges, formats, and size limits at the boundary.
- Missing rate limiting on login, signup, password reset, or expensive endpoints.

## Severity

Rank by exploitability and impact together.

- Critical: remote, unauthenticated, or trivially exploitable; leads to code execution, full
  data access, or auth bypass.
- High: exploitable by an authenticated user or with modest effort; leads to cross-user data
  access, privilege escalation, or secret exposure.
- Medium: needs unusual conditions or chaining; limited impact.
- Low: defense-in-depth gap or hardening issue with no direct attack path.

## Finding format

Number findings `SEC-1`, `SEC-2`, and so on, ordered most severe first.

```markdown
### SEC-1 [Critical] Short imperative title
- Location: `path/to/file.ext:LINE`
- Category: <category from the list above, and CWE ID if known>
- Confidence: Confirmed | Likely | Needs verification
- Data flow: entry point -> ... -> sink, with file:line for each step.
- Attack scenario: What an attacker sends or does, and what they gain.
- Remediation: The exact fix, with a short code sketch if it helps.
- Proof: The test that would demonstrate the fix works.
```

## Report

```markdown
# Security Review

**Target:** <what you reviewed>
**Files reviewed:** N
**Tools run:** <scanner/audit results, or "none">

## Attack surface
Entry points and sensitive sinks found, one line each.

## Findings
<findings in the format above, or "No findings.">

## Categories checked and clean
Short list of categories with no findings.

## Verdict
Ship / Ship after fixes / Do not ship, with one short paragraph explaining why.

## Fix list
IDs of Confirmed and Likely findings that the fixer should address, most severe first.
Findings marked "Needs verification" go in a separate list with what would confirm them.
```
