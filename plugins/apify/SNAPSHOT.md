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

The entire upstream repository tree verbatim: `.mcp.json`, `agents/apify.md` (the
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

## This plugin DOES bundle an MCP server — deliberately

Unlike `exa` and `firecrawl-workflows`, this plugin ships `.mcp.json` pointing at the
**official hosted Apify MCP server** (`https://mcp.apify.com/`, streamable HTTP).
That is the plugin's entire purpose: installing it connects the session to Apify.
It is safe to commit because the URL carries **no secret** — authentication is an
OAuth flow handled by Claude Code on first use (contrast with Firecrawl, whose
server URL embeds an API key and therefore must never be bundled).

Caveat: if a session already has its own Apify MCP server configured at user or
project scope, enabling this plugin runs a second connection to the same service
and duplicates its toolset. Keep exactly one enabled.

## How to update this snapshot

1. `git clone https://github.com/apify/apify-claude-code-plugin` somewhere outside
   this repo and note `git rev-parse HEAD`.
2. Diff against `plugins/apify/` (ignoring `.git`, `.claude-plugin/marketplace.json`,
   and the removed `version` field).
3. Copy changes in, keeping the exclusions and the `version` removal.
4. Update the commit/date table above and commit.
