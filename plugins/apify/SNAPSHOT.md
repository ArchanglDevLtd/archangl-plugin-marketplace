# Vendored snapshot: apify

This plugin is a **frozen, verbatim copy** of Apify's official Claude Code plugin,
vendored into this marketplace on purpose so that installing from this marketplace
never reaches out to any repo other than this one, and so upstream churn cannot
change behavior under us. It is **not** sourced live from the upstream repo, and
must never be converted to a remote `source` or a dependency on the upstream
marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/apify/apify-claude-code-plugin |
| Snapshot commit | `06125313a553abafeff09f50ed848c5d2a7b4662` |
| Commit subject | `Merge pull request #7 from apify/apify-plugins-sync/e1592b68` |
| Commit date | 2026-06-22 |
| Snapshot taken | 2026-07-10 |

## What was copied

The entire upstream repository tree verbatim: `agents/apify.md` (the
routing subagent), the five skills (`apify-actor-development`, `apify-actorization`,
`apify-generate-output-schema`, `apify-sdk-integration`, `apify-ultimate-scraper`),
`README.md`, `CHANGELOG.md`, and `LICENSE` (Apache-2.0, © Apify — retained for
attribution).

Excluded during the copy:

- `.git/` — upstream history (the snapshot pins by the SHA above).
- `.claude-plugin/marketplace.json` — upstream's own single-plugin marketplace
  manifest. This repo's root marketplace lists the plugin instead, and
  `.claude-plugin/` here holds only `plugin.json` (repo rule 1).

## Changes from upstream

- **`plugin.json` `version` (was `1.0.0`) was removed** so this repo's commits drive
  updates (repo rule 3). Every other manifest field is verbatim.
- **Upstream's `.mcp.json` was removed** (it pointed at the hosted Apify MCP server,
  `https://mcp.apify.com/`). See below.

## This plugin bundles NO MCP server — same rule as `exa`

Upstream ships `.mcp.json` connecting the session to the official hosted Apify MCP.
That block was **deliberately removed** from this snapshot: the owner already runs a
**session-scoped Apify MCP server**, and bundling a second connection to the same
service duplicates the toolset and produces unpredictable tool resolution — the exact
failure mode that led to stripping the MCP block from the `exa` plugin (see
`plugins/exa/SNAPSHOT.md`).

Do **not** re-add `.mcp.json` (or an `mcpServers` block in `plugin.json`) to this
plugin. The `apify` agent and skills call Apify MCP tools that resolve to the
owner's session-scoped server. Upstream's `README.md` still describes the bundled
`.mcp.json` — that wording is kept as part of the snapshot; in the owner's sessions
the MCP surface it describes is provided by the session-scoped server instead.

(The removal is not a secrets issue — the URL carries no key, auth is OAuth — purely
a duplicate-connection issue. If the session-scoped server ever goes away, restoring
upstream's `.mcp.json` verbatim is the correct way to re-enable the connection.)

## How to update this snapshot

1. `git clone https://github.com/apify/apify-claude-code-plugin` somewhere outside
   this repo and note `git rev-parse HEAD`.
2. Diff against `plugins/apify/` (ignoring `.git`, `.claude-plugin/marketplace.json`,
   the removed `.mcp.json`, and the removed `version` field).
3. Copy changes in, keeping the exclusions, the `version` removal, and the
   `.mcp.json` removal.
4. Update the commit/date table above and commit.
