# Security Standards

Assume code will run in a hostile environment.

## Secrets
- Never hardcode secrets.
- Read secrets from environment variables.
- Do not log secrets.

## Input Handling
- Validate and sanitize all external input.
- Treat user input, file input, and network data as untrusted.

## Privilege
- Follow least-privilege principles.
- Avoid requiring root unless strictly necessary.

## Command Execution
- Avoid shell injection risks.
- Use safe subprocess calls with argument lists.

## Failures
- Fail closed instead of fail open.
