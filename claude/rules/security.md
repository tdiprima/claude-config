# Security Rules

Apply these rules whenever you write, edit, or review code.

## 1. Insecure Direct Object References (IDOR)
- **Always enforce resource ownership at the database query level.** When accessing a user-owned resource, scope the query using the authenticated user's ID or tenant ID obtained from the verified server-side session. Never trust ownership identifiers supplied by the client. Return `404` when the resource does not exist or is not accessible to the user. UUIDs do not replace ownership checks.

## 2. Server-Side Authorization
- **Never rely on frontend checks to enforce permissions.** Every protected API endpoint must authenticate the request and verify that the authenticated user is authorized to perform the requested action on the target resource. Apply authorization checks before reads, updates, or destructive operations. Deny access by default when permission cannot be established.

## 3. Secrets Management
- **Never hardcode, expose, log, or commit secrets.** Do not read or print the contents of `.env` files. Use environment variable names documented in `.env.example`, which must contain placeholder values only. Ensure `.env` is included in `.gitignore` before making the first commit. If a secret is exposed, treat it as compromised and rotate it before cleaning up the exposure.

## 4. Tokens and Sessions
- **Follow secure token and session management practices.** Prefer a maintained authentication library or provider over implementing authentication manually. Use short-lived access tokens (typically 5–15 minutes) and revocable, rotating refresh tokens stored server-side in hashed form. Store refresh tokens in `HttpOnly`, `Secure`, and appropriately configured `SameSite` cookies. Always verify token signatures and explicitly pin the accepted algorithm. Regenerate session IDs after login and privilege changes. Never disable signature verification.

## 5. SQL Injection
- **Always use parameterized queries or safe ORM operations.** Never construct SQL statements by concatenating or interpolating untrusted input into query strings. Apply the same rule when using raw SQL or ORM escape hatches. If an LLM generates SQL, execute it using a read-only database role with statement timeouts enforced.

## 6. Cross-Site Scripting (XSS)
- **Treat all user-generated content as untrusted when rendering it in the browser.** Rely on contextual output escaping by default. Do not bypass escaping with mechanisms such as Django's `mark_safe()` or React's `dangerouslySetInnerHTML` unless the content has been properly sanitized. Sanitize Markdown that permits raw HTML. Avoid storing sensitive authentication tokens in `localStorage`.

## 7. Cross-Site Request Forgery (CSRF)
- **Protect every state-changing request that authenticates with cookies.** Use the framework's built-in CSRF protection and never disable it to make a request work. Set `SameSite=Lax` or `Strict` on session cookies. Never change state in a `GET` handler. Do not exempt an endpoint from CSRF checks unless it authenticates with a non-cookie credential such as a bearer token.

## 8. Server-Side Request Forgery (SSRF)
- **Never fetch a URL supplied by a user without validating its destination.** Allow only `http` and `https`. Prefer an allowlist of hosts. Resolve the hostname and reject loopback, private, link-local, and cloud metadata addresses (for example `169.254.169.254`), then connect to the address you validated so DNS rebinding cannot swap it. Do not follow redirects without re-validating each hop. Set timeouts and response size limits.

## 9. Command Injection
- **Never pass untrusted input to a shell.** Call programs with an argument list and no shell (for example `subprocess.run([...])` without `shell=True`, or `execFile` instead of `exec`). Prefer a library call over spawning a process. Validate arguments against an allowlist, and place `--` before user-supplied values so they cannot be read as options. Never pass untrusted input to `eval`, `exec`, or unsafe deserializers such as `pickle`.

## 10. Path Traversal and File Uploads
- **Never build a filesystem path directly from user input.** Resolve the final path and confirm it stays inside the intended base directory before opening it. For uploads, generate the stored filename on the server, enforce a size limit, and validate the type against an allowlist using the file content rather than the client-supplied name or `Content-Type`. Store uploads outside the web root, never execute them, and serve them with `Content-Disposition: attachment` and `X-Content-Type-Options: nosniff`. Guard archive extraction against entries that escape the target directory.

## 11. Input Validation
- **Validate all external input on the server at the trust boundary.** Use a schema validation library to check type, length, range, and format, and reject input that fails rather than trying to repair it. Prefer allowlists over denylists. Bind only explicitly permitted fields to models to prevent mass assignment. Validation complements, and never replaces, parameterized queries and output escaping.

## 12. CORS
- **Allow only the specific origins that need access.** Never combine `Access-Control-Allow-Origin: *` with credentials, and never reflect the request's `Origin` header back without checking it against an allowlist. Do not allow the `null` origin. Restrict allowed methods and headers to those actually used. CORS is not an authorization mechanism; endpoints still need server-side checks.

## 13. Rate Limiting
- **Rate limit authentication and other abuse-prone endpoints.** Cover login, registration, password reset, token refresh, and any endpoint that is expensive or sends email or SMS. Limit by both account and client IP, enforce the limit on the server, and return `429` with a `Retry-After` header. Add lockout or increasing delays after repeated failed logins. Cap request body size and pagination limits.

## 14. Dependency Pinning
- **Pin dependencies to exact versions and commit the lockfile.** Install from the lockfile in CI and production (for example `npm ci`, or `pip install --require-hashes`). Before adding a package, confirm the name is correct and the package is maintained, to avoid typosquatted or abandoned packages. Do not add a dependency for a few lines of code. Run the ecosystem's audit tool and do not ignore known vulnerabilities. Pin CI actions and base images to a commit SHA or digest.

## 15. No PII in Logs
- **Never log personal or sensitive data.** This includes passwords, tokens, session IDs, API keys, full request or response bodies, emails, phone numbers, addresses, government IDs, payment data, and health data. Log an internal user ID or a redacted value instead. Configure redaction in the logger rather than relying on each call site. Do not include sensitive data in error messages returned to clients, in URLs, or in analytics events.
