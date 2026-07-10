# Setup

## ctx7 setup

One-time command to configure Context7 for your AI coding agent. This
marketplace uses **CLI + Skills mode only** — it installs a `find-docs` skill
that guides the agent to use `ctx7` CLI commands. Always pass `--cli`.

```bash
ctx7 setup --cli               # CLI + Skills mode

# Target a specific install location
ctx7 setup --cli --claude      # Claude Code (~/.claude/skills)
ctx7 setup --cli --cursor      # Cursor (~/.cursor/skills)
ctx7 setup --cli --universal   # Universal (~/.agents/skills)
ctx7 setup --cli --antigravity # Antigravity (~/.config/agent/skills)

ctx7 setup --project           # Configure current project instead of globally
ctx7 setup --yes               # Skip confirmation prompts
```

**Authentication options:**
```bash
ctx7 setup --api-key YOUR_KEY  # Use an existing API key
```

Without `--api-key`, setup opens a browser for OAuth login. Keep keys out of
the repo and out of conversations — seed them into the environment instead.

**What gets written — CLI + Skills mode:**
- A `find-docs` skill in the chosen agent's skills directory, guiding the agent to use `ctx7 library` and `ctx7 docs` commands

Note: in sessions using this marketplace, the `find-docs` skill already ships
inside this plugin, so `ctx7 setup` is usually unnecessary — install the CLI
(`npm install -g ctx7@latest`) and go.
