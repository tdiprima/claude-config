# Configuration Standards

## Sources
Configuration should support:

1. Environment variables (primary)
2. Optional configuration file (secondary)

## Behavior
- Provide sane defaults.
- Validate configuration at startup.

## Security
- Never store secrets in configuration files.
- Secrets must come from environment variables.
