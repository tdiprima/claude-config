---
name: project-memory  
description: Set up and maintain a structured project memory system in docs/project_notes/  
  that tracks bugs with solutions, architectural decisions, key project facts, and work  
  history. Use this skill when asked to "set up project memory", "track our decisions",  
  "log a bug fix", "update project memory", or "initialize memory system".
---

# Project Memory Skill

## When to Use This Skill

Invoke this skill when:

- Starting a new project that will accumulate knowledge over time
- The project already has recurring bugs or decisions that should be documented
- The user asks to "set up project memory" or "track our decisions"
- Encountering a problem that feels familiar ("didn't we solve this before?")
- Before proposing an architectural change (check existing decisions first)

## Core Capabilities

### 1. Initial Setup - Create Memory Infrastructure

When invoked for the first time in a project, create the following structure:

```
docs/
└── project_notes/
    ├── bugs.md         # Bug log with solutions
    ├── decisions.md    # Architectural Decision Records
    ├── key_facts.md    # Project configuration and constants
    └── issues.md       # Work log with ticket references
```

**Directory naming rationale:** Using `docs/project_notes/` instead of `memory/`
makes it look like standard engineering documentation, not AI-specific tooling.

### 2. Bug Entry Format

When logging a bug, use this format in `docs/project_notes/bugs.md`:

### YYYY-MM-DD - BUG-XXX: Bug Title

**Issue**: What happened

**Root Cause**: Why it happened

**Solution**: How you fixed it

**Prevention**: How to avoid it next time

### 3. Decision Entry Format

When recording a decision, use this format in `docs/project_notes/decisions.md`:

### ADR-XXX: Decision Title

**Date**: YYYY-MM-DD

**Status**: Active | Superseded by ADR-XXX

**Context**: Why this decision was needed

**Decision**: What was decided

**Alternatives**: What else was considered

**Consequences**: What this means going forward

### 4. Configure CLAUDE.md - Memory-Aware Behavior

Add or update the following section in the project's `CLAUDE.md` file:

## Project Memory System

### Memory-Aware Protocols

**Before proposing architectural changes:**

- Check `docs/project_notes/decisions.md` for existing decisions
- Verify the proposed approach doesn't conflict with past choices

**When encountering errors or bugs:**

- Search `docs/project_notes/bugs.md` for similar issues
- Apply known solutions if found
- Document new bugs and solutions when resolved

**When looking up project configuration:**

- Check `docs/project_notes/key_facts.md` for ports, URLs, environment info
- Prefer documented facts over assumptions

**When completing work:**

- Log completed work in `docs/project_notes/issues.md`

**When making decisions:**

- Record architectural decisions in `docs/project_notes/decisions.md`

### 5. Security Rules

**NEVER store in any memory file:**

- Passwords, API keys, access tokens
- Service account keys or private keys
- OAuth secrets or refresh tokens
- Database connection strings with passwords
- SSH keys or VPN credentials

**Safe to store:**

- Hostnames and URLs
- Port numbers
- Project IDs
- Environment names (staging, production, dev)
- Non-sensitive configuration values
