# Vendored snapshot: exa

This plugin is a **frozen copy** of the Exa plugin, vendored into this marketplace
on purpose so upstream churn cannot change behavior under us. It is not sourced live
from the upstream repo or marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/exa-labs/exa-mcp-server |
| Snapshot commit | `c4b419adb3ce2674ad062b15f0d42f8b8cee05c5` |
| Commit date | 2026-06-30 |
| Upstream `version` at snapshot | `3.3.10` |
| Snapshot taken | 2026-07-07 |

## What was copied

- `.claude-plugin/plugin.json` — see change below
- `skills/` — the two skills the plugin ships:
  - `skills/search` → invoked as `/exa:search` (frontmatter name `search`; the "Exa
    Research Orchestrator")
  - `skills/agent` → invoked as `/exa:exa-agent` (frontmatter name `exa-agent`; async
    Exa Agent runs, enrichment, list-building)
- `LICENSE` — upstream license, retained for attribution

The upstream repo is primarily the source for the Exa **MCP server** (`src/`,
`tests/`, `api/`, `package.json`, `Dockerfile`, `llm_mcp_docs.txt`, etc.). Upstream
has the plugin connect to Exa's **hosted** HTTP MCP endpoint
(`https://mcp.exa.ai/mcp`) itself; this snapshot does not (see below), so none of
that server code is needed at runtime and was intentionally not copied.

## Changes from upstream

- `version` was removed from `plugin.json` so this repo's git commit SHA drives
  versioning and propagation (see `CLAUDE.md`). The upstream value (`3.3.10`) is
  recorded above. The manifest declares no `skills` array; both skills load via the
  default scan of `skills/`, exactly as upstream ships it.
- `plugin.json`'s `mcpServers` block (pointing at `https://mcp.exa.ai/mcp`) was
  **removed** on 2026-07-07. Upstream has the plugin provision its own hosted Exa
  MCP server. That collided with sessions that already have their own Exa MCP
  server configured and OAuth'd — the plugin would stand up a second, unauthenticated
  `exa` server alongside it, and which one a skill's tool calls resolved to became
  unpredictable. The skills reference tools by bare name (`web_search_exa`,
  `agent_create_run`, etc.), not by fully-qualified `mcp__exa__...` names, so they
  work against whichever MCP server in the session exposes those tools — dropping
  the bundled server is safe and makes this plugin lean on the session's own Exa MCP
  connection instead of provisioning a competing one.

## Auth note

This plugin no longer provisions an Exa MCP server itself — it expects one to
already be connected in the session (the user's own MCP config, OAuth'd or with an
API key). See `skills/search/SKILL.md` → "Prerequisites: Auth" for what to tell the
user if no Exa MCP tools are available.

## Refreshing this snapshot

Re-clone upstream, diff against this directory, copy in intended changes, update the
commit/date/version above, and commit — always as a deliberate act.
