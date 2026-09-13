---
name: code-review
description: Review-only engineering review of a code change for correctness bugs, edge cases, error handling, complexity, duplication, dead code, and performance. Produces a severity-ranked findings report and never edits code. Use after a builder agent finishes a feature or diff. Not for security (use security-review), tests (use test-review), or system design (use architecture-review).
metadata:
  short-description: Correctness and maintainability review
---

# Code Review

Review this change as a senior software engineer. Your job is to find real defects,
not to approve the code and not to rewrite it.

## Scope

If the user names a target (file, directory, glob, commit, branch, or PR), review that.
Otherwise use the first one that applies:

1. Staged changes: `git diff --cached`
2. Unstaged changes: `git diff`
3. Branch changes: `git diff $(git merge-base HEAD <default-branch>)`
4. Otherwise ask the user what to review. Do not guess.

Read the full changed files and enough surrounding code, callers, and tests to confirm each
finding. If the repo has a `.codegraph` folder or codegraph tools, use them to find callers
and impact. State the exact target at the top of the report.

## Rules

- Review only. Do not edit, create, or delete files. Do not commit. Fixing is a separate step.
- If the project has a linter, type checker, or test command already configured, you may run
  it and report the result. Do not install anything.
- Report only problems you can demonstrate from the code. Style preferences are not defects.
- Continue through the whole change after the first finding.
- If a category is clean, say so. Do not invent findings to fill the report.
- Skip generated code, vendored dependencies, lockfiles, and build output unless included.

## Check for

- Correctness bugs: wrong logic, off-by-one, wrong operator, inverted condition, wrong units.
- Edge cases and failure modes: empty, null, zero, negative, duplicate, very large, unicode,
  missing files, timeouts, partial failure.
- Error handling: swallowed exceptions, bare `except`/empty `catch`, errors logged but not
  surfaced, misleading error messages, fail-open behavior.
- Resource leaks: files, sockets, DB connections, locks, subprocesses, or temp files not
  released on every path, including error paths.
- Race and concurrency problems: shared mutable state, check-then-act, missing locks or
  transactions, non-atomic counters.
- Unnecessary complexity: deep nesting, long functions that do more than one job, clever code
  a tired maintainer cannot follow.
- Duplicated code: logic copied instead of reused, a new helper that duplicates an existing one.
- Dead or unreachable code: unused imports, variables, functions, flags, commented-out blocks.
- Weak abstractions: wrappers that add nothing, leaky abstractions, wrong responsibility split.
- Performance problems that realistically matter: N+1 queries, I/O inside loops, unbounded
  result sets, quadratic work on real data sizes, blocking calls on hot paths.
- Dependency misuse: new dependency where the standard library works, deprecated API,
  unpinned version.
- Leftover AI artifacts: placeholder values, TODO stubs presented as done, hallucinated APIs
  or config keys, comments that describe code that no longer exists.

## Severity

- Critical: data loss or corruption, crash on a normal path, silent wrong results.
- High: likely bug in a realistic scenario, swallowed error, resource leak.
- Medium: fragile code, edge case that will fail eventually, significant maintainability cost.
- Low: small clarity or cleanup issue that still has a concrete benefit.

## Finding format

Number findings `CR-1`, `CR-2`, and so on, ordered most severe first.

```markdown
### CR-1 [High] Short imperative title
- Location: `path/to/file.ext:LINE`
- Confidence: Confirmed | Likely | Needs verification
- Problem: Why this is wrong.
- Failure scenario: Concrete input or state, and the wrong result it produces.
- Fix: The specific change to make.
```

## Report

```markdown
# Code Review

**Target:** <what you reviewed>
**Files reviewed:** N
**Checks run:** <linter/type checker/tests run and their result, or "none">

## Findings
<findings in the format above, or "No findings.">

## Summary
| Severity | Count |
|----------|-------|
| Critical | N |
| High     | N |
| Medium   | N |
| Low      | N |

## Verdict
Ship / Ship after fixes / Do not ship, with one short paragraph explaining why.

## Fix list
IDs of Confirmed and Likely findings that the fixer should address, most severe first.
Findings marked "Needs verification" go in a separate list with what would confirm them.
```
