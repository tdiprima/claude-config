---
paths:
  - "**/*.py"
---

# Python Coding Standards

## Readability
- Optimize for **human readability** over cleverness.
- Prefer explicit code over implicit behavior.

## Functions
- Keep functions small.
- Add concise docstrings explaining the function's purpose.

## Imports
- Avoid unused imports.
- Prefer standard library when possible.

## Subprocess
- Avoid `shell=True`.
- Always validate inputs before executing external commands.
