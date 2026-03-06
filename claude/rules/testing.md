# Testing Standards

## Testability
- Separate business logic from side effects.

Examples of side effects:
- filesystem
- network
- subprocess
- database access

## Design
- Keep pure logic in isolated functions.

## Requirements
- Logic should be testable without root privileges.
- Avoid environment-specific dependencies in core logic.
