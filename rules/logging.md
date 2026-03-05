# Logging Standards

## Logging System
- Use the Python `logging` module.

## Requirements
- No `print` statements in production code.
- Support log level configuration via environment variables.

## Structured Logs
Prefer structured logs where possible.

Example fields:
- event
- component
- status

## Security
- Never log secrets.
- Avoid logging sensitive data.
