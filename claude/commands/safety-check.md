# For vetting untrusted code

Review this codebase and answer: **If I run this, could it grab my personal information or harm my computer?**

## Goal

Assess what the code does and whether it is safe to run locally.

## Check for

- Data exfiltration to Discord, Slack, Telegram, webhooks, unknown APIs, or attacker-controlled servers
- Access to personal files such as:
  - `~/.ssh`
  - `~/.aws`
  - browser profiles/cookies/password stores
  - keychains
  - environment variables
  - crypto wallets
- Hidden or encoded payloads
- Dangerous dynamic execution such as:
  - `eval()`
  - `exec()`
  - `Function()`
  - `os.execute`
  - `io.popen`
  - shell/process spawning
- Credential harvesting
- File writes, persistence, startup modifications, or system configuration changes
- Hardcoded IPs, suspicious domains, C2 behavior, or phone-home logic

## Look for Traps
* A wire phoning home (reverse shell)
* A second mechanism doing damage (`rm -rf`)
* Parts wrapped in tape (obfuscated code)
* Payload staging notes

## Output format

Provide a concise security report:

| Concern | Status | Evidence |
|---|---|---|
| Reads local personal files | Present / Not present / Unclear | File paths or code references |
| Executes shell commands | Present / Not present / Unclear | Code references |
| Writes files to disk | Present / Not present / Unclear | Code references |
| Sends data to external servers | Present / Not present / Unclear | URLs, APIs, or code references |
| Hardcoded IPs/URLs | Present / Not present / Unclear | Values found |
| Obfuscated/encoded payloads | Present / Not present / Unclear | Code references |
| Modifies system configuration | Present / Not present / Unclear | Code references |
| Harvests credentials/secrets | Present / Not present / Unclear | Code references |

## Final verdict

End with one of:

- **Safe to run**
- **Likely safe, but review notes first**
- **Do not run**
- **Unclear — needs manual review**

Include a brief explanation for the verdict and mention the exact files/functions that influenced it.
