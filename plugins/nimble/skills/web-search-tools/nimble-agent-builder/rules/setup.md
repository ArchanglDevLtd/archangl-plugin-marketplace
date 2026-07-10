---
description: One-time setup for Nimble Agent Builder. Load when the CLI is not available.
alwaysApply: false
---

# Nimble Agent Builder Setup

The `nimble` CLI is the only transport. Setup is two steps: install the CLI,
seed `NIMBLE_API_KEY` into the environment.

## CLI install

```bash
npm i -g @nimble-way/nimble-cli
nimble --version
```

The CLI authenticates with the `NIMBLE_API_KEY` environment variable. In
managed/cloud environments it is seeded by the environment's startup
configuration; on a local machine set it once:

```bash
export NIMBLE_API_KEY="your-api-key-here"
```

For the full setup flow (API-key generation, permanent storage in
`~/.claude/settings.json`, docs access), see
`skills/web-search-tools/nimble-web-expert/rules/setup.md`. Never ask the user
to paste an API key into the conversation.
