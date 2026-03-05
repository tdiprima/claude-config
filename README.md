Bet 😄 here's the "set it once, never paste that mega-prompt again" Claude Code setup — global + per-project, with copy/paste templates.

Everything below matches Claude Code docs for where stuff lives + how it's scoped. ([Claude][1])

---

## The big picture

Claude Code has **layers**. Higher priority overrides lower priority:

1. **Org-managed policy** (IT/MDM)
2. **Your global** (~/.claude/...)
3. **Project** (repo/.claude/...)
4. **Local project** (repo/.claude/settings.local.json)

Locations + precedence are explicitly documented. ([Claude][1])

---

## 0) Optional: org-wide "managed policy" CLAUDE.md (not you, usually)

If you're in an org that pushes standards, they can deploy a CLAUDE.md that applies to everyone and can't be excluded: ([Claude][1])

* macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
* Linux/WSL: `/etc/claude-code/CLAUDE.md`
* Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`

---

## 1) Your global setup (the good stuff)

### Recommended `~/.claude` layout

```text
~/.claude/
├── CLAUDE.md
├── rules/
│   ├── preferences.md
│   ├── security.md
│   └── python-devsecops.md
├── agents/
│   ├── security-reviewer.json
│   └── code-quality.json
└── tasks/
    └── (auto-created by Claude Code)
```

* **Global CLAUDE.md** applies to *all sessions*. ([Claude][1])
* **Global rules** in `~/.claude/rules/` are also supported and load before project rules. ([Claude][1])
* **User subagents** live in `~/.claude/agents/`. ([Claude][2])
* **Task lists** can persist in `~/.claude/tasks/`. ([Claude][3])

### Create the folders

```bash
mkdir -p ~/.claude/{rules,agents}
```

(Tasks folder will appear when Claude uses it.)

---

## 2) Global `CLAUDE.md` (keep it short + universal)

Docs note: CLAUDE.md is **context**, not "hard enforcement", so short + specific wins. ([Claude][1])

**`~/.claude/CLAUDE.md`**

```md
# Global instructions (apply to all projects)

## Non-negotiables
- Never output or log secrets. If a secret appears, redact it.
- Prefer secure defaults. Validate inputs. Fail clearly.
- Avoid `subprocess(..., shell=True)` unless explicitly required.

## How to work with me
- Ask 1-2 clarifying questions only if absolutely blocking; otherwise make the best safe assumption and proceed.
- Optimize for readability over cleverness.
```

Why keep it minimal? Because project-specific rules belong in project files or path-scoped rules. ([Claude][1])

---

## 3) Global `.claude/rules/` (your "modular rule pack")

This is the move when your rules are long: split them into themed files, and even scope them by paths if you want. ([Claude][1])

### Example: `~/.claude/rules/python-devsecops.md`

```md
# Python DevSecOps standards

- Use structured logging via `logging` (no prints).
- Never hardcode secrets; read from env.
- Keep main.py orchestration-only.
- Separate pure logic from side effects for testability.
```

### Example: path-scoped rule (only loads for certain files)

```md
---
paths:
  - "**/*.py"
---
# Python-only rules

- Prefer type hints.
- Avoid deep nesting.
```

Path-scoped rules are a first-class thing in `.claude/rules/`. ([Claude][1])

---

## 4) Global settings (permissions, env passthrough, hooks, MCP)

Claude Code settings are in:

* **User**: `~/.claude/settings.json` ([Claude][4])
* **Project**: `.claude/settings.json` (shared) ([Claude][4])
* **Local project**: `.claude/settings.local.json` (personal) ([Claude][4])

Start with **user settings** so every repo behaves consistently.

**`~/.claude/settings.json` (starter example)**

```json
{
  "env": {
    "LOG_LEVEL": "INFO"
  }
}
```

(Keep it conservative. Tighten/expand tools & permissions later as you learn your comfort level.)

---

## 5) Per-project setup (so teams share rules)

Recommended repo structure:

```text
your-repo/
├── CLAUDE.md              # or .claude/CLAUDE.md
└── .claude/
    ├── settings.json
    ├── rules/
    │   ├── security.md
    │   ├── testing.md
    │   └── code-style.md
    ├── skills/
    │   └── review/
    │       └── SKILL.md
    └── agents/
        └── repo-reviewer.json
```

* Project CLAUDE.md can live at `./CLAUDE.md` or `./.claude/CLAUDE.md`. ([Claude][1])
* Project rules directory `.claude/rules/` is the "modular rules" system. ([Claude][1])

### Monorepo trick: parent + child CLAUDE.md

Claude walks upward from your cwd and loads ancestor CLAUDE.md, and only pulls in child CLAUDE.md on demand when it touches those directories. ([Claude][1])

---

## 6) Skills & custom commands (your reusable workflows)

Claude Code merged "custom commands" into **skills**:

* Old: `.claude/commands/review.md`
* New: `.claude/skills/review/SKILL.md`

Both create `/review` and work the same; skills add extra features + supporting files. ([Claude][5])

### Example skill: `.claude/skills/security-review/SKILL.md`

```md
---
description: "Run a security-focused review of the current changes."
---
When invoked, do the following:
1) Identify the files changed.
2) Look for secrets, auth mistakes, unsafe subprocess usage, injection risks.
3) Output: findings grouped by severity with concrete fixes.
4) Never include sensitive values in output.
```

Now you can type: `/security-review`

---

## 7) Subagents (specialist modes you can summon)

If you want a dedicated "Security Reviewer" brain, create a user-level subagent — stored at `~/.claude/agents/` so it works everywhere. ([Claude][2])

Use `/agents` in Claude Code to generate/manage them (docs show user-level vs project-level). ([Claude][2])

---

## 8) Hooks (deterministic enforcement)

When you want "this ALWAYS runs" (formatters, tests, policy checks), hooks are the tool because they run shell commands at lifecycle moments. ([Claude][6])

Rule of thumb:

* **CLAUDE.md / rules** = "how to behave"
* **Hooks** = "this must happen, no matter what"

---

## 9) MCP (only if you need external tools)

MCP is for connecting Claude Code to external systems (APIs, DBs, ticketing, etc.). It's not for style guides. ([Claude][7])

So: use MCP when you need *capabilities*, not *preferences*.

---

## 10) Output styles (optional: controls response vibe, not rules)

Output styles affect system-prompt behavior; CLAUDE.md is added as a user message after the default system prompt. ([Claude][8])

If you just want "always write concise / always write with explanations", output styles can help. But for coding standards, stick to CLAUDE.md + rules.

---

## 11) Quality-of-life pro moves

### A) Import files into CLAUDE.md

You can keep CLAUDE.md short and "pull in" other docs using `@path`. ([Claude][9])

### B) Exclude noisy monorepo instructions

Use `claudeMdExcludes` if other teams' CLAUDE.md files are getting sucked in. ([Claude][1])

### C) Persist task lists across sessions

Set `CLAUDE_CODE_TASK_LIST_ID` to keep a named task list directory in `~/.claude/tasks/`. ([Claude][3])

---

## The "just do this" setup checklist

1. Create:

```bash
mkdir -p ~/.claude/{rules,agents}
```

2. Put your universal rules in:

* `~/.claude/CLAUDE.md` ([Claude][1])

3. Put your long detailed standards in:

* `~/.claude/rules/*.md` ([Claude][1])

4. For each repo, add:

* `repo/CLAUDE.md` (team shared) and/or `repo/.claude/rules/` ([Claude][4])

[1]: https://code.claude.com/docs/en/memory "How Claude remembers your project - Claude Code Docs"
[2]: https://code.claude.com/docs/en/sub-agents "Create custom subagents - Claude Code Docs"
[3]: https://code.claude.com/docs/en/interactive-mode "Interactive mode - Claude Code Docs"
[4]: https://code.claude.com/docs/en/settings "Claude Code settings - Claude Code Docs"
[5]: https://code.claude.com/docs/en/skills "Extend Claude with skills - Claude Code Docs"
[6]: https://code.claude.com/docs/en/hooks-guide "Automate workflows with hooks - Claude Code Docs"
[7]: https://code.claude.com/docs/en/mcp "Connect Claude Code to tools via MCP - Claude Code Docs"
[8]: https://code.claude.com/docs/en/output-styles "Output styles - Claude Code Docs"
[9]: https://code.claude.com/docs/en/best-practices "Best Practices for Claude Code - Claude Code Docs"

<br>
