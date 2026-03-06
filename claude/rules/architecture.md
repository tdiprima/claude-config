# Software Architecture Rules

## Structure
- Break solutions into multiple files when appropriate.
- Each file must have a **single responsibility**.
- Each function must do **one thing only**.

## Naming
- Use explicit, descriptive function names.
- Avoid single-letter variable names.

## Main Entry Point
- Keep `main.py` small and orchestration-only.

## Complexity
- Avoid large monolithic classes unless necessary.
- Avoid deep nesting.
- Avoid dense abstraction layers.
