---
name: test-review
description: Review-only assessment of whether tests actually prove a change works and is safe. Checks coverage of changed behavior, edge cases, failure paths, adversarial and abuse cases, test quality, and whether tests would catch a broken implementation. Proposes the missing tests but never writes or edits them. Use after code-review or before merging. Not for reviewing production code logic (use code-review).
metadata:
  short-description: Coverage, edge-case, and adversarial test review
---

# Test Review

Tests are executable evidence. AI review is only opinion. Your job is to decide whether the
tests prove that this change works and fails safely, and to list exactly which tests are
missing.

## Scope

If the user names a target (file, directory, glob, commit, branch, or PR), review that.
Otherwise use the first one that applies:

1. Staged changes: `git diff --cached`
2. Unstaged changes: `git diff`
3. Branch changes: `git diff $(git merge-base HEAD <default-branch>)`
4. Otherwise ask the user what to review. Do not guess.

For each changed production file, find the tests that exercise it, including tests outside
the diff. If the repo has a `.codegraph` folder or codegraph tools, use them to find callers
and test references. State the exact target at the top of the report.

## Rules

- Review only. Do not write, edit, or delete tests or code. Do not commit. Writing the missing
  tests is a separate step.
- If the project has a test command already configured, run it and report the exact result
  (pass/fail counts, failures). If coverage tooling is already configured, run it too. Do not
  install anything.
- Judge tests against the intended behavior, not against what the code happens to do. A test
  that asserts current buggy output is a defect.
- If an area is well tested, say so. Do not invent findings to fill the report.

## Check for

- Missing coverage: changed functions, branches, and error paths with no test at all.
- Happy-path-only tests: no test for failure modes, invalid input, or error returns.
- Write tests that actively try to break the system.
- Edge cases: empty input, null/None, zero, negative numbers, boundary values (min, max,
  max+1), duplicates, very large input, unicode, already-sorted or degenerate input, mixed types.
- Adversarial and abuse cases for anything reachable by untrusted input:
  - missing or invalid authentication
  - altered IDs to reach another user's resources (IDOR)
  - malformed and oversized input
  - injection payloads (SQL, shell, path traversal, HTML/script)
  - invalid state transitions (for example, pay before checkout, reuse a spent token)
  - repeated and concurrent requests (double submit, race on counters or balances)
- Security claims without proof: if the code claims "only the owner can access this", there
  must be a test showing a different user is refused.
- Weak assertions: tests that only check "no exception" or status 200, snapshot tests nobody
  reads, assertions on mocks instead of behavior.
- Over-mocking: mocks that replace the logic under test, so the test cannot fail.
- Tests that mirror the implementation: expected values computed with the same code being
  tested.
- Flaky tests: real time, real network, random data without a seed, order dependence, sleeps.
- Test hygiene: shared mutable fixtures, tests that depend on other tests, skipped or
  disabled tests with no reason, missing cleanup of files or DB rows.
- Mutation resistance: for the most important logic, name one small change to the
  implementation (flip a condition, drop a check, change a boundary) and say whether any
  existing test would fail. If none would, the tests are insufficient.

## Severity

- Critical: security or data-integrity behavior with no test, or a test suite that fails.
- High: changed logic with no tests, or only happy-path tests for code that handles untrusted
  input.
- Medium: missing edge cases, weak assertions, or flaky tests.
- Low: test clarity or hygiene issue.

## Finding format

Number findings `TEST-1`, `TEST-2`, and so on, ordered most severe first.

```markdown
### TEST-1 [High] Short imperative title
- Code under test: `path/to/file.ext:LINE` (function or endpoint name)
- Existing tests: `path/to/test_file.ext:LINE`, or "none"
- Confidence: Confirmed | Likely | Needs verification
- Gap: What behavior is not proven.
- Risk: The bug that could ship without this test.
- Proposed test: Test name, input, and expected result, in one or two lines.
```

## Report

```markdown
# Test Review

**Target:** <what you reviewed>
**Test command:** <command run and result, or "not run: reason">
**Coverage:** <numbers if available, otherwise "not measured">

## Findings
<findings in the format above, or "No findings.">

## Mutation check
| Change to implementation | Would a test fail? |
|--------------------------|--------------------|
| <small change>           | Yes (test name) / No |

## Verdict
Tests are sufficient / Tests need additions before merge / Tests do not prove the change works,
with one short paragraph explaining why.

## Tests to write
Ordered list of the proposed tests the fixer should add, most important first.
```
