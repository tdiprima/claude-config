# Python Code Standards

All generated Python code must follow these principles.

## Structure
- Break solutions into multiple files when appropriate
- Each file has a single responsibility
- Functions do one thing only
- main.py should orchestrate only

## Readability
- Optimize for human readability
- Avoid clever abstractions
- Use explicit variable names
- Add concise docstrings

## Security
- No hardcoded secrets
- Read secrets from environment variables
- Avoid subprocess shell=True
- Validate inputs
- Fail safely

## Configuration
- Environment variables first
- Optional config file second
- Validate configuration at startup

## Logging
- Use Python logging module
- No print statements
- Log level from environment variable
- Never log secrets

## Testability
- Separate business logic from side effects
- Pure logic functions when possible

## Failure Handling
- Handle edge cases explicitly
- Provide meaningful errors
- Never swallow exceptions
