---
name: architecture-review
description: Review-only architecture review of a change or codebase. Explains the system to the maintainer in plain language (components, data flow, trust boundaries, where auth happens), then finds design problems such as tangled boundaries, tight coupling, wrong responsibility split, and unnecessary complexity. Never edits code. Use after a feature lands or before building on top of it. Not for line-level bugs (use code-review) or vulnerabilities (use security-review).
metadata:
  short-description: Boundaries, coupling, data flow, and complexity review
---

# Architecture Review

The maintainer did not write this code and may not read every line. Give them an accurate
mental model of the system, show where the design is risky, and tell them which parts
deserve their personal attention.

## Scope

If the user names a target (file, directory, glob, commit, branch, or PR), review that.
Otherwise use the first one that applies:

1. Staged changes: `git diff --cached`
2. Unstaged changes: `git diff`
3. Branch changes: `git diff $(git merge-base HEAD <default-branch>)`
4. No pending changes: review the whole repository.

Architecture is about how the change fits the whole system. Read the project layout, entry
points, README, and any `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, or `docs/adr/` files. If the
repo has a `.codegraph` folder or codegraph tools, use them to map modules and dependencies.
State the exact target at the top of the report.

## Rules

- Review only. Do not edit, create, or delete files. Do not commit. Refactoring is a separate
  step.
- Explain at the level of components and data flow, not line by line.
- Use plain language. Define any term the maintainer might not know.
- Report design problems only when you can name a concrete cost: a likely bug, a change that
  will be hard to make, a test that cannot be written, or a security boundary that is unclear.
- Do not recommend a large rewrite when a small change fixes the problem.
- If the design is sound, say so. Do not invent findings to fill the report.

## Part 1: Explain the system

Describe, briefly:

- Components: which files or modules were added or changed, and what each one is responsible
  for.
- Data flow: how a typical request or job moves through the system, from entry to output.
- Trust boundaries: where external or untrusted data enters.
- Authentication and authorization: where identity is checked and where permissions are
  enforced.
- Sensitive operations: where the code touches secrets, money, user data, the file system,
  subprocesses, or external services.
- What could break: the most likely failure points (external dependencies, shared state,
  assumptions about input or environment).
- Security assumptions: what the code assumes is true but does not enforce (for example,
  "runs behind a proxy that authenticates users").

Include a small text diagram of the main data flow when it helps.

## Part 2: Find design problems

Check for:

- Boundary violations: HTTP, business logic, and data access mixed in one place; UI code
  calling the database; business logic depending on framework objects.
- Tight coupling: modules that reach into each other's internals, circular dependencies, one
  change forcing edits in many files.
- Wrong responsibility split: a "god" module or class, one function doing several jobs, the
  same concept implemented in two places.
- Unnecessary complexity: layers, interfaces, factories, or config systems with a single use;
  abstractions added "for later"; frameworks where a function would do.
- Unclear data ownership: several places writing the same state, no single source of truth,
  shared mutable globals.
- Scattered cross-cutting concerns: auth, validation, error handling, or logging done
  differently in each place instead of once at a clear boundary.
- Hidden side effects: I/O or network calls inside functions whose names suggest pure logic,
  making the code hard to test.
- Testability: core logic that cannot be tested without a network, database, root access, or
  the real file system.
- Configuration and secrets: config mixed into code, secrets not isolated to environment
  variables, no validation at startup.
- Scale assumptions: designs that work for 10 records but not 10,000 (unbounded loads,
  in-memory state that should be persistent, synchronous work that should be queued).

## Severity

- Critical: design makes a security boundary or data integrity unenforceable.
- High: design will cause bugs or blocks safe change in an area that is actively developed.
- Medium: design adds real maintenance cost or makes testing hard.
- Low: small structural cleanup with a clear benefit.

## Finding format

Number findings `ARCH-1`, `ARCH-2`, and so on, ordered most severe first.

```markdown
### ARCH-1 [High] Short imperative title
- Location: `path/to/module/` or `path/to/file.ext:LINE`
- Confidence: Confirmed | Likely | Needs verification
- Problem: What is wrong with the structure.
- Cost: The concrete bug, change, or test this makes hard.
- Recommendation: The smallest structural change that fixes it.
```

## Report

```markdown
# Architecture Review

**Target:** <what you reviewed>

## How the system works
<Part 1, in plain language>

## Findings
<findings in the format above, or "No findings.">

## Five places to understand personally
The five parts of this codebase where a mistake would be most dangerous, each with a file
path and one sentence on why it matters.

## Verdict
Sound / Sound with fixes / Needs redesign before building further, with one short paragraph
explaining why.

## Fix list
IDs of Confirmed and Likely findings worth addressing, most severe first.
```
