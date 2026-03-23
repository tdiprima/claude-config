# Backend JavaScript/Node.js Best Practices

## Prime Directive: Stupid Simple Code

Write code that a tired developer at 2am can read and understand immediately. Clever code is bad code. Simple code is good code. If you have to think hard to understand what a line does, rewrite it.

## Architecture: Layers, Not Blobs

Never cram validation, business logic, and database calls into route handlers. Use distinct layers:

1. **Routes/Controllers** — Accept the request, call a service, return the response. That's it.
2. **Services** — Business logic lives here. No HTTP objects (`req`, `res`), no SQL.
3. **Repositories/Data Access** — All database queries isolated here. Nothing else touches the DB directly.

```js
// BAD — everything jammed into the route
app.post("/posts", async (req, res) => {
  if (!req.body.title) return res.status(400).send("Missing title");
  const post = await Post.create(req.body);
  res.send(post);
});

// GOOD — each layer does one job
router.post("/posts", postController.create);

// controller
async function create(req, res, next) {
  try {
    const post = await postService.create(req.body);
    res.status(201).json(post);
  } catch (err) {
    next(err);
  }
}

// service
async function create(data) {
  validate(data);
  return postRepository.insert(data);
}
```

This means when the database or ORM changes, you fix one layer, not the whole app.

## Input Validation

Never trust data from clients. Ever.

- Check required fields exist.
- Enforce types, lengths, and ranges.
- Validate formats (emails, dates, IDs).
- Reject bad input early — at the boundary, before it reaches business logic.
- Client-side validation is for UX. Server-side validation is for safety. Always do both.

## Error Handling

- Never let an unhandled error crash silently or return a raw stack trace to the client.
- Use a centralized error handler middleware. Don't scatter try/catch with `res.status(500)` in every route.
- Return consistent error response shapes so consumers can rely on them.

```js
// Consistent shape — always
{
  "success": false,
  "error": "VALIDATION_ERROR",
  "message": "Title is required"
}
```

- Use custom error classes (e.g., `NotFoundError`, `ValidationError`) so your central handler can map them to the right HTTP status codes.
- Log every error server-side. Return a safe, generic message client-side. Never leak internals.

## Logging

`console.log` is not a logging strategy.

- Use structured logging (JSON format) so logs are searchable and parseable.
- Log at appropriate levels: `info` for normal flow, `warn` for recoverable issues, `error` for failures.
- Log at boundaries: incoming requests, outgoing responses, auth events, DB errors, external API calls.
- Include context: request IDs, user IDs, timestamps. A log line with no context is useless.
- Never log sensitive data (passwords, tokens, PII).

## Database Design

- Add indexes on columns you query frequently. Missing indexes are the #1 cause of slow backends.
- Use the right data types. Don't store dates as strings. Don't store booleans as integers.
- Normalize your schema, but don't over-normalize to the point where every read requires five joins.
- Always use parameterized queries or ORM bindings. Never concatenate user input into SQL strings.
- Plan for how your queries will look before finalizing your schema — design for the access patterns.

## Security

- Hash passwords with bcrypt or argon2. Never store them in plain text. Never use MD5 or SHA for passwords.
- Authenticate and authorize every endpoint. Don't assume the client checked permissions.
- Rate-limit sensitive endpoints (login, signup, password reset). Use exponential backoff for repeated failures.
- Sanitize all user input. Escape output to prevent injection (SQL, NoSQL, command injection).
- Never put secrets in source code. Use environment variables or a secrets manager.
- Use HTTPS everywhere. Set security headers (`Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`).
- Validate JWTs properly — check expiration, issuer, audience. Don't just decode and trust.
- Apply the principle of least privilege to database users, API keys, and service accounts.
- Keep dependencies updated. Run `npm audit` regularly.

## Scalability

- Never return unbounded result sets. Always paginate: `?page=1&limit=20` or cursor-based.
- Cache expensive reads (Redis, in-memory) and invalidate deliberately.
- Use async job queues for slow work (sending emails, processing images, generating reports). Don't block the request.
- Design endpoints to be stateless. Don't store session state in-memory on the server.
- Index before you scale. Most "scaling problems" are actually query problems.

## Thinking About Failure

Assume everything will fail, because it will.

- Database will be slow sometimes. Set timeouts and handle them.
- External APIs will be down. Use retries with backoff and circuit breakers.
- Two requests will hit the same resource at the same time. Handle concurrency and race conditions.
- Disk will fill up. Memory will spike. Network will drop. Code for it.
- Test the unhappy paths, not just the happy ones.

## Naming

- Variables and functions: use descriptive, full English words. `getUserEmail()` not `getUE()`. `isValid` not `iv`.
- Booleans start with `is`, `has`, `can`, `should`: `isAuthenticated`, `hasPermission`, `canRetry`.
- Name things for what they ARE or what they DO, never for how they're implemented.

## Functions

- Each function does ONE thing. If you describe it with "and", split it.
- Keep functions short. If it doesn't fit on one screen (~30 lines), break it up.
- Prefer named functions over anonymous ones. They show up in stack traces.
- Avoid nesting more than 2 levels deep. Use early returns to flatten logic.
- No magic numbers or magic strings. Use named constants.

## Async Code

- Use `async/await` over `.then()` chains.
- Always handle errors with try/catch around await calls.
- Never use `async` on a function that doesn't `await` anything.
- If you fire off a promise without awaiting it, add a `.catch()` so errors don't vanish.

## General Rules

- Use `const` by default. Use `let` only when you need to reassign. Never use `var`.
- Always use `===`. Never use `==`.
- Keep third-party dependencies to a minimum.
- Prefer early returns over deeply nested if/else chains.
- Don't comment WHAT the code does. Comment WHY it does something non-obvious.
- No premature optimization. Write it simple first. Measure, then optimize.
- Separate configuration from code. Different environments should use different config, not different code.
