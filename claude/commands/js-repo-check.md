# JavaScript Repo Health Check

Audit this JavaScript repository for test quality, correctness, and resilience. Use your own judgment and analysis in addition to the guidelines below — these are starting points, not an exhaustive checklist.

## 1. Behavior vs. Implementation Testing

Scan test files for signs of implementation-coupled tests:
- Excessive `jest.spyOn` or mock assertions that verify *which internal functions were called* rather than *what the output was*
- Tests that break on harmless refactors (e.g., renaming an internal helper)
- Tests asserting on internal state instead of observable behavior (API responses, rendered UI, return values)

Flag tests that would break if the implementation changed but the behavior stayed correct.

## 2. Edge Case and Unhappy Path Coverage

For each module with tests, check whether the test suite covers:
- Invalid, empty, null, and undefined inputs
- Boundary values (0, -1, MAX_SAFE_INTEGER, empty strings, empty arrays)
- Network/IO failure scenarios (rejected promises, timeouts, malformed responses)
- Concurrent or out-of-order operations where applicable
- Authorization failures and missing/expired credentials

Flag modules where tests only cover the happy path.

## 3. Property-Based and Generative Testing

Look for functions that operate on arbitrary input (sorting, filtering, transforming, encoding/decoding, serialization) and check whether any property-based or fuzz-style tests exist. Note opportunities where property-based testing would add value — especially for pure functions with well-defined invariants.

## 4. Production Safety Patterns

Check for:
- Feature flag usage and whether flagged code paths have tests for both on/off states
- Graceful degradation and fallback paths under failure
- Health check or synthetic monitoring endpoints
- Environment-specific configuration that could diverge between test and production

## 5. Mutation Resilience

Pick 3-5 critical functions (payment processing, auth, data validation, core business logic). Mentally mutate them:
- Flip a comparison operator (`>=` to `>`, `===` to `!==`)
- Remove a guard clause or early return
- Delete a line of logic

Would the existing tests catch these mutations? Flag tests that would still pass after meaningful code changes.

## 6. Test-First Indicators

Look for signs the test suite was written after the fact rather than test-first:
- Tests that mirror implementation line-by-line instead of specifying behavior
- Missing tests for error cases that the code handles (catch blocks with no corresponding test)
- Test descriptions that describe *code* rather than *requirements* ("calls handleSubmit" vs. "rejects submission when required fields are missing")

## Beyond the Guidelines

Also apply your own analysis. Look for anything else that weakens the repo's reliability:
- Flaky tests (timing-dependent, order-dependent, environment-dependent)
- Overly broad mocks that hide real integration issues
- Dead or skipped tests (`xit`, `test.skip`, `.only` left in)
- Missing tests for exported public API surface
- Test coverage that inflates numbers without verifying meaningful behavior
- Security-sensitive code paths lacking test coverage (auth, input sanitization, access control)
- Dependency on deprecated or unmaintained test utilities

## Output Format

For each finding:
1. **File and line** where the issue lives
2. **What's wrong** — one sentence
3. **Why it matters** — what could slip through
4. **Suggested fix** — concrete, not vague

Group findings by severity: critical first, then moderate, then minor. End with a short summary of overall test health.
