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
`tests/`, `api/`, `package.json`, `Dockerfile`, `llm_mcp_docs.txt`, etc.). This
plugin connects to Exa's **hosted** HTTP MCP endpoint (`https://mcp.exa.ai/mcp`),
so none of that server code is needed at runtime and was intentionally not copied.

## Only change from upstream

`version` was removed from `plugin.json` so this repo's git commit SHA drives
versioning and propagation (see `CLAUDE.md`). The upstream value (`3.3.10`) is
recorded above. The manifest declares no `skills` array; both skills load via the
default scan of `skills/`, exactly as upstream ships it.

## Auth note

The hosted Exa MCP works anonymously (rate-limited); OAuth or an API key raises
limits. See `skills/search/SKILL.md` → "Prerequisites: Auth".

## Refreshing this snapshot

Re-clone upstream, diff against this directory, copy in intended changes, update the
commit/date/version above, and commit — always as a deliberate act.
