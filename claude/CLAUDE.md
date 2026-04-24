# Global Development Principles

Follow secure, production-quality engineering practices.

## Core Principles
- Prioritize **clarity and maintainability** over cleverness.
- Prefer **simple, modular architecture**.
- Each function should do **one clearly defined job**.
- Validate all external input.
- Fail safely with clear error messages.
- Use the DRY principles; do not repeat yourself.
- Do not repeat code; reuse functions and fields.

## Security Defaults
- Never hardcode secrets.
- Read secrets from environment variables.
- Do not log sensitive values.
- Use least-privilege assumptions.
- Assume the runtime environment may be hostile.

## Reliability
- Handle errors explicitly.
- Avoid silent failures.
- Prefer deterministic behavior and predictable outputs.

## Logging
- Use structured logging when possible.
- Avoid `print` in production code.

If project-specific rules exist, follow those instead.

Write for Ubuntu, RHEL, and Rocky Linux - NOT macOS.
