# Claude Config

This repository stores my Claude configuration files so they can be quickly set up on a new machine.

Instead of copying files into `~/.claude`, this repo uses a **symlink approach** so the configuration is always synced with the repository.

## Installation

Clone the repository:

```bash
git clone <repo-url>
cd <repo-name>
```

Run the setup script:

```bash
./link.sh
```

This will:

1. Check for an existing `~/.claude`
2. Back it up if it exists
3. Create a symlink from:

```sh
~/.claude → <repo>/claude
```

## Why Use a Symlink?

Benefits of this setup:

- Changes to the repo immediately affect Claude
- No need to copy or sync files
- Easy to version control config changes
- Faster setup on new machines

## Updating Configuration

Just edit the files in the repo:

```sh
claude/
```

Claude will immediately use the updated configuration.

## Backup Behavior

If `~/.claude` already exists, the script will rename it:

```sh
~/.claude.backup.TIMESTAMP
```

Example:

```sh
~/.claude.backup.20260306_153211
```

## Restore Backup (if needed)

```sh
rm ~/.claude
mv ~/.claude.backup.TIMESTAMP ~/.claude
```

## Notes

Do **not** store secrets in this repository:

- API keys
- tokens
- credentials
- private endpoints

Use environment variables or secret managers instead.

<br>
