# Secure Production Code Prompt

<!-- Inspired by: https://medium.com/javarevisited/10-proven-ways-i-instantly-spot-bad-ai-generated-code-8bb671dce517 -->

Use the following instructions for all code you generate. These are non-negotiable constraints.

## SQL and Database Queries

- Use only parameterized queries or an ORM. No string concatenation in SQL, ever.
- No f-strings, `+` concatenation, or template literals near any database query.
- Batch all database reads. No queries inside loops. Use `IN` clauses, bulk fetches, or eager loading to avoid N+1 patterns.

## Secrets and Credentials

- Load all credentials from environment variables or a secrets manager.
- Never hardcode API keys, passwords, tokens, or connection strings.
- If a required credential is missing at startup, throw an error and exit immediately.

## Error Handling

- Every exception must be caught with a specific exception type, logged with context (what failed, which record, what input), and converted to a domain-appropriate error.
- No bare `except:`, no `except Exception: pass`, no empty `catch (e) {}` blocks.
- Silent failures are bugs. If something fails, the system must log it, alert on it, or surface it to the caller.

## Input Validation and Edge Cases

- Validate all external input at the boundary: check types, lengths, ranges, formats, and reject bad input early with clear error messages.
- Before writing any function, identify every failure mode first: null/empty inputs, oversized inputs, path traversal, malformed data, concurrent access, and boundary values.
- Write guard clauses and early returns. Production code is defensive at the door.

## Authorization and Access Control

- Every API endpoint that touches user data must include authentication middleware and an ownership or role check before any database call.
- Never go straight from request parameters into a database query without verifying the caller has permission to access that resource.
- Apply row-level security where the database supports it.

## Concurrency and Shared State

- For any code path that touches money, inventory, counters, or shared mutable state, assume 100 concurrent requests hit this function simultaneously.
- Use row-level locks, database transactions, or atomic operations to prevent race conditions.
- Identify what breaks under concurrency and fix it before the code is considered complete.

## Dependencies and Libraries

- Only use well-established, actively maintained packages. Verify every suggested dependency exists on the official registry (npm, PyPI, etc.) and check its publish date, download count, and repository activity.
- Never use deprecated libraries or APIs. Use current, secure alternatives: bcrypt or argon2 for password hashing (never MD5 or SHA-1), current TLS versions, and actively supported framework features.
- Pin exact dependency versions in lockfiles.

## Testing

- Write tests from the specification, not from the implementation. Tests must verify correct behavior, not mirror what the code happens to do.
- Every test suite must include: empty inputs, null values, duplicates, boundary values, extremely large inputs, already-sorted or degenerate inputs, negative numbers, mixed types where applicable, and at least one adversarial or malicious input.
- For concurrent code paths, write load tests with concurrent users before merging.
- After writing tests, mutate the implementation and confirm that at least one test fails. If no test fails, the tests are insufficient.

## Security Defaults

- Sanitize all output to prevent XSS. Use `textContent` over `innerHTML`, use framework escaping mechanisms, and never build HTML from user-supplied strings.
- Apply the principle of least privilege to database users, API keys, and service accounts.
- Set security headers: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`.
- Validate JWTs fully: check expiration, issuer, and audience.

## Performance Awareness

- Code must work at production scale, not just with test data. Consider what happens with 10,000 records, not 10.
- Identify and eliminate N+1 query patterns, unbounded result sets, and synchronous blocking on slow operations.

## Code Review Checklist

Before considering any code complete, verify:

1. No string concatenation in SQL queries
2. No hardcoded secrets anywhere in the code
3. All error paths are handled, logged, and surfaced
4. All inputs are validated at the boundary
5. All endpoints have auth and authorization checks
6. Shared state is protected against concurrent access
7. All dependencies are real, current, and pinned
8. Tests cover edge cases, not just the happy path
9. No N+1 queries or unbounded loops with I/O
10. Output is sanitized against injection attacks
