# Claude Config

Portable Claude Code configuration with coding rules, custom skills, and a bootstrap script for fast machine setup.

## Starting Fresh Shouldn't Mean Starting Over

Every time you provision a new machine, you end up reconfiguring your tools from scratch — hunting down the same settings, recreating the same workflows, and hoping you remember everything you had before. With an AI assistant like Claude Code, that friction compounds: your rules, skills, and behavioral guidelines live nowhere persistent by default.

## A Single Command That Rebuilds Your Claude Environment

This repo stores your complete Claude Code setup under version control — coding standards, security rules, language-specific guidelines, and reusable skills — and symlinks it into `~/.claude` where Claude Code expects it. Clone it on any machine and run one script to get your full environment back.

### What gets installed:
- `CLAUDE.md` — core development principles Claude follows across all projects
- `rules/` — language and domain-specific coding standards (Python, Bash, security, logging, testing, and more)
- `skills/` — reusable slash commands: `/review`, `/threat-model`, `/project-memory`

## Example

On a freshly provisioned machine:

```bash
git clone https://github.com/tdiprima/claude-config
cd claude-config
./bootstrap.sh
```

Claude Code is installed, and `~/.claude` is symlinked to your repo. Any edits you make are version-controlled automatically.

To re-link without reinstalling Claude:

```bash
./link.sh
```

If `~/.claude` already exists, `link.sh` backs it up with a timestamp before creating the symlink — nothing is overwritten silently.

## Usage

| Script | What it does |
|---|---|
| `bootstrap.sh` | Installs Claude Code and links this repo to `~/.claude` |
| `link.sh` | Links this repo to `~/.claude` only (skips Claude install) |

**Add your own rules** by dropping a Markdown file into `claude/rules/`. Claude Code picks them up automatically.

**Add your own skills** by creating a `claude/skills/<name>/SKILL.md` file. Invoke them with `/<name>` inside any Claude session.
