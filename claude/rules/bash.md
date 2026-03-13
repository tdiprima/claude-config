# Bash Scripting Instructions

## Prime Directive: Stupid Simple Code

Write bash scripts that a tired developer at 2 AM can read and understand immediately. Clarity beats cleverness every single time. If a construct requires a mental pause to parse, rewrite it more simply.

## Structure & Safety

- Start every script with `#!/usr/bin/env bash`
- Always use `set -euo pipefail` right after the shebang
- Use `set -x` during development for trace debugging, remove it before committing

## Readability Over Brevity

- Use long-form flag names: `--recursive` not `-r`, `--force` not `-f`
- Use `if/then/else/fi` instead of `&&/||` chains for anything beyond trivial one-liners
- One command per line. Never chain with `;` unless it's genuinely trivial
- Break long pipelines across multiple lines with trailing `\` or put each stage on its own line inside a function
- Use `$(command)` for substitution, never backticks
- Quote every variable: `"${my_var}"`, no exceptions
- Use `[[ ]]` for conditionals, never `[ ]`

## Naming

- Variables: `snake_case`, all lowercase — `input_file`, `retry_count`
- Constants/environment: `UPPER_SNAKE_CASE` — `MAX_RETRIES`, `BASE_URL`
- Functions: `snake_case` verbs — `build_artifact`, `validate_input`
- Scripts: `kebab-case` — `deploy-app.sh`, `run-tests.sh`
- Booleans: name them so the meaning is obvious — `is_ready`, `has_errors`, `should_retry`

## Functions

- Every function gets a short comment explaining what it does
- Keep functions short — if it scrolls off screen, split it
- Use `local` for all variables inside functions
- Return values via `echo` (stdout), not global variables
- Put the "main" logic in a `main()` function, call it at the bottom: `main "$@"`

## Error Handling

- Validate inputs early and fail fast with clear error messages
- Write error messages to stderr: `echo "ERROR: file not found: ${path}" >&2`
- Use meaningful exit codes, not just 0 and 1
- Wrap cleanup logic in a `trap` on EXIT
- When a command might fail, handle it explicitly — don't rely on `set -e` for flow control

## Comments

- Comment the WHY, not the WHAT — `# Retry because the API rate-limits after 100 calls` not `# retry the request`
- Add a header comment block at the top of every script explaining what it does, what it expects, and what it produces
- Mark hacks and workarounds with `# HACK:` or `# WORKAROUND:` and explain why

## Arguments & Input

- Use `getopts` or a simple `while/case` loop for argument parsing — skip heavy frameworks
- Always provide a `--help` / `-h` flag
- Provide sensible defaults for optional arguments
- Validate required arguments are present before doing any work

## Things to Avoid

- No single-letter variable names except `i`, `j` in short loops
- No `eval` unless there is genuinely no other option (there almost always is)
- No unquoted variables, ever
- No hardcoded paths — use variables or derive them from the script's location
- No clever parameter expansion tricks that require looking up the bash manual — write it out plainly
- No deeply nested if/else — restructure with early returns or guard clauses
- Don't parse `ls` output — use globs or `find`
- Don't use `cat file | grep` — just `grep pattern file`

## Testing & Debugging

- Test scripts with `shellcheck` before considering them done
- Add a `--dry-run` flag for destructive operations
- Log what the script is doing at each major step so failures are easy to trace
