# Vibe Coding Review Kit

Four review-only AI reviewers (code, security, tests, architecture) that run in both Claude Code and Codex, installed with one script.

## "It works" is not the same as "it's good"

AI coding assistants write working software quickly. The catch is that working software can still be AI slop: duplicated logic, swallowed errors, security holes, giant functions, and tests that only prove the happy path. When the code is too complex to read line by line, "it runs" becomes the only quality check.

Asking a second model "does this look good?" doesn't fix that. A vague question gets a vague answer, usually "looks pretty good, here are three minor suggestions." And when a reviewer is allowed to fix what it finds, it tends to rewrite code quietly instead of giving you a clear, honest assessment.

## A builder, a panel of reviewers, and a paper trail

This kit splits the work so the model that builds a feature is not the one that grades it. Claude Code (or Codex) builds, then four focused reviewers each do one job:

| Reviewer | What it looks for |
| --- | --- |
| `code-review` | Correctness bugs, edge cases, error handling, resource leaks, concurrency, duplication, dead code, performance that matters, leftover AI artifacts |
| `security-review` | OWASP-style review that traces untrusted input from where it enters to dangerous sinks (SQL, shell, file paths, HTML, outbound requests), covering auth/IDOR, injection, SSRF, secrets, crypto misuse, and supply-chain risk |
| `test-review` | Whether the tests actually prove the change works: coverage, edge cases, abuse cases such as altered IDs or oversized input, weak assertions, over-mocking, and a mutation check ("would any test fail if this condition were flipped?") |
| `architecture-review` | A plain-language explanation of how the system works (components, data flow, trust boundaries, where auth happens), then design problems such as tangled layers, tight coupling, and unnecessary complexity |

Every reviewer follows the same rules:

- **Review only.** Reviewers never edit, create, or delete files. Fixing is a separate, deliberate step.
- **Evidence, not opinion.** Each finding needs a `file:line` location, a concrete failure or attack scenario, and a specific fix. Style preferences are not reported as defects.
- **Honest confidence.** Findings are tagged Confirmed, Likely, or Needs verification, so the fixer only acts on what is real.
- **A clean handoff.** Each report ends with a verdict (Ship / Ship after fixes / Do not ship) and a numbered fix list you can paste straight to the builder.

Each reviewer is packaged as a skill (the full instructions) and as an agent (a thin, read-only wrapper that loads the skill). The skill text exists once and is shared by both tools, so changing a checklist updates Claude Code and Codex together.

## What a finding looks like

This is an illustrative finding in the format `security-review` produces:

```markdown
### SEC-1 [High] Enforce ownership check before returning invoices
- Location: `app/routes/invoices.py:42`
- Category: Authorization / IDOR (CWE-639)
- Confidence: Confirmed
- Data flow: GET /invoices/<invoice_id> (routes/invoices.py:38) -> get_invoice(invoice_id)
  (services/billing.py:17) -> SELECT by id only (repositories/invoices.py:9)
- Attack scenario: A logged-in user changes the invoice ID in the URL and reads any
  other customer's invoice, including name, address, and amount.
- Remediation: Pass the current user's ID to the repository and query by both
  invoice ID and owner ID; return 404 when no row matches.
- Proof: Test that user B requesting user A's invoice receives 404.
```

`architecture-review` also ends every report with **"Five places to understand personally"**: the parts of the codebase where a mistake would be most dangerous, so you know where to spend your own attention.

## Install and use

### Install

Requirements: Bash, plus Claude Code and/or Codex. Tested on macOS; the script avoids GNU-only flags so it also runs on Linux.

```bash
git clone <this-repo> vibe-coding-workflow
cd vibe-coding-workflow
./install.sh --dry-run   # preview every change, write nothing
./install.sh
```

The script installs:

| Path | Contents |
| --- | --- |
| `~/.codex/skills/<name>/` | Skill instructions (the single source of truth) |
| `~/.claude/skills/<name>` | Symlink to the Codex skill |
| `~/.claude/agents/<name>.md` | Claude Code subagent, limited to Read, Grep, Glob, and Bash |
| `~/.codex/agents/<name>.toml` | Codex agent role with a read-only sandbox |

Useful details:

- Safe to rerun. Files that already match are skipped.
- An existing file that differs is left alone and reported. Rerun with `--force` to replace it; the original is backed up as `<file>.bak.<timestamp>`.
- Respects `CLAUDE_CONFIG_DIR` and `CODEX_HOME` if you keep your config somewhere other than `~/.claude` and `~/.codex`.
- `./install.sh --help` lists all options.

### Run a review

With no target, each reviewer checks staged changes first, then unstaged changes, then the current branch against the default branch. `architecture-review` reviews the whole repository if nothing is pending; the other three ask you what to review. You can also name a file, directory, commit, or branch.

In **Claude Code**, ask for an agent by name:

```text
Use the security-review agent on my staged changes.
Use the test-review agent on src/billing/.
```

`/test-review` and `/architecture-review` also work as slash commands. Claude Code's built-in `/code-review` and `/security-review` take priority over skills with the same names, so use the agents for those two.

In **Codex**, use the skills directly or ask for the agents:

```text
$code-review
$architecture-review
```

### The recommended loop

1. Build a small feature with Claude Code. Small diffs are easier to audit.
2. Run your existing linters, type checker, and tests.
3. Run `code-review` and `security-review`, ideally in the other tool, so a different model reviews the code.
4. Run `test-review` to confirm the tests prove the behavior, especially the abuse cases.
5. Give the builder the fix list and have it fix only Confirmed and Likely findings.
6. Rerun the tests and the same reviewers to verify the fixes.
7. After larger changes, run `architecture-review` to keep your mental model of the system current.

<br>
