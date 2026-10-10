# Claude Config

Portable Claude Code configuration: global rules, custom commands, skills, and two scripts that get it all onto a new machine.

## Why

Claude Code reads its global config from `~/.claude`. By default that directory lives on one machine, unversioned. Reinstall your laptop, get a second workstation, or spin up a dev VM, and every rule and slash command you've tuned is gone.

This repo keeps `~/.claude` under version control. Clone it anywhere, run one script, and Claude behaves the same way it does on your main machine.

## What's inside

```
claude/              <- becomes ~/.claude
  CLAUDE.md          global principles Claude follows in every project
  rules/             per-language and per-domain standards (python, bash, js, security, testing, logging, ...)
  commands/          slash commands (/readme, /explain-code, /secure-code-review, /tags, ...)
  skills/            skills (/review, /threat-model)
vibe-coding-workflow/   separate review kit for Claude Code + Codex (has its own README and installer)
bootstrap.sh         new-machine setup: deps check + install Claude Code + link config
link.sh              symlink claude/ -> ~/.claude (used by bootstrap.sh)
```

## Use case: new laptop, same Claude in five minutes

You get a fresh Mac. Nothing is installed. You want Claude Code running with your Python rules, your security rules, and your `/secure-code-review` command before you write a line of code.

```bash
git clone https://github.com/tdiprima/claude-config
cd claude-config
./bootstrap.sh
```

That's it. Claude Code is installed, `~/.claude` points at `claude/` in this repo, and every edit you make to a rule or command from now on is a normal git change you can commit and pull on your other machines.

## bootstrap.sh vs link.sh

| | `bootstrap.sh` | `link.sh` |
|---|---|---|
| Checks for `git`, `curl`, `rsync` | yes | no |
| Installs Claude Code (if missing) | yes | no |
| Symlinks `claude/` to `~/.claude` | yes (by calling `link.sh`) | yes |
| Backs up an existing `~/.claude` | yes (via `link.sh`) | yes, to `~/.claude.backup.<timestamp>` |
| When to run | new machine | Claude already installed, just need the link |

**Do you need to run both? No.** `bootstrap.sh` calls `link.sh` at the end, so running `bootstrap.sh` does everything.

Run `link.sh` on its own only when Claude Code is already installed and you just want the symlink, for example:

- You cloned the repo on a machine that already has Claude Code.
- You moved the repo to a new path and need to re-point `~/.claude`.
- `~/.claude` got replaced by a real directory and you want the symlink back.

Both scripts are safe to re-run. If `~/.claude` already points at this repo, `link.sh` exits without changing anything.

## Customizing

- **Add a rule:** drop a Markdown file in `claude/rules/`. Claude Code loads it automatically.
- **Add a slash command:** create `claude/commands/<name>.md`. Invoke with `/<name>`.
- **Add a skill:** create `claude/skills/<name>/SKILL.md`. Invoke with `/<name>`.

## License

MIT. See [LICENSE](LICENSE).
