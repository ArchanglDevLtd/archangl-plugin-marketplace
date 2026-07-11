# Vendored snapshot: archangl-apify

This plugin is a **frozen consolidation of two upstream Apify repos** into one
first-party-curated plugin, vendored so that installing from this marketplace
never reaches out to any repo other than this one. It must never be converted
to a remote `source` or split back into upstream-tracking pieces.

| | |
| --- | --- |
| Upstream repo 1 | https://github.com/apify/awesome-skills |
| Pinned commit 1 | `34f67cd` (2026-06-28) |
| Upstream repo 2 | https://github.com/apify/agent-skills |
| Pinned commit 2 | `7eb6296` (2026-06-25) |
| Snapshot taken | 2026-07-10 |
| Spec | issue #9 |

## What was copied

Union of all skills — **17 total** after restructuring (no name collisions):

- From **awesome-skills** (9 top-level): ads-intelligence, ai-search-visibility-tracker,
  booking-host-leads, easy-competitive-intelligence, ecommerce,
  influencer-brand-collabs, link-prospecting-outreach, verified-email-finder,
  x402-agentic-wallet — plus the **apify-financial-services bundle**, whose three
  sub-skills (financial-news, financial-osint, public-registries) were **hoisted**
  to top-level skills (see below).
- From **agent-skills** (5): actor-development, actorization,
  generate-output-schema, sdk-integration, ultimate-scraper.
- Commands: `create-actor` (agent-skills) and `portfolio-sweep` (hoisted from the
  financial-services bundle).
- `data/companies.json` + `data/README.md` hoisted to the plugin root (the
  financial skills reference `${CLAUDE_PLUGIN_ROOT}/data/companies.json`, which
  only resolves at the plugin root).
- Licenses: Apache-2.0 (both upstream repos, `LICENSE`) and MIT for the
  financial-services bundle (© pavel242242, kept as `LICENSE.financial-services`).

Excluded during the copy:

- `.git/`, `.DS_Store`, both upstream `.claude-plugin/` manifests (this repo's
  marketplace lists the plugin; the manifest here is authored, no `version`).
- `skills/_template/` (repo tooling; its options B/C documented MCP transports).
- Both repos' `agents/AGENTS.md`, `scripts/` (generate_agents tooling), CI
  workflows, and `gemini-extension.json` — repo tooling that advertises the MCP
  connector.
- `skills/apify-financial-services/.claude-plugin/plugin.json` — a **nested
  plugin manifest inside a skill directory** (declared "apify-financial-services"
  v1.2.0). There is no plugin-inside-a-plugin here: its skills/command/data were
  hoisted, the manifest and its `AGENTS.md` dropped.
- `skills/apify-link-prospecting-outreach/reference/` upstream retains no MCP
  files needing exclusion; `references/mcp-setup`-style files did not exist in
  these repos (no `.mcp.json`/`mcpServers` anywhere upstream).

## Changes from upstream — the MCP strip (CLI/REST is the only transport)

Transport contract: the **`apify` CLI** (`npm install -g apify-cli`; auth via
`apify login` or an environment-seeded **`APIFY_TOKEN`**) and the **Apify REST
API** (same token) are the only transports. Per-skill:

- **Prose strips (CLI already primary):** booking-host-leads (MCP-alternatives
  line deleted), easy-competitive-intelligence (MCP fallback → stop-and-guide),
  financial-news + financial-osint (MCP connector fallback removed from
  prerequisites and Step 0; SOURCE_CONFIGS "MCPC" wording → apify CLI),
  actor-development + actorization ("MCP tools" sections with an Apify docs MCP
  url and a Playwright `mcpServers` install block → a Bash Playwright
  browser-debugging note; "MCP servers" in Standby-mode lists → "tool servers"),
  sdk-integration (`search-actors`/`fetch-actor-details` → `apify actors ls
  --search` / `apify actors info --input`; docs-MCP paragraph removed),
  create-actor command (MCP tools block removed, docs links kept).
- **verified-email-finder:** upstream's "MCP path (default)" removed; the script
  path is the only path, with CLI equivalents documented (`apify actors call`,
  `apify api /v2/datasets/<id>/items`); examples and troubleshooting updated.
- **influencer-brand-collabs:** `mcp__claude_ai_Apify__*` tool calls →
  `apify actors call` / `apify actors info --input`; README requirements updated.
- **public-registries (owner-approved script port):** the DE, UK, and RO
  `fetch_all.py` scripts structurally embedded the `mcpc` MCP client; their
  transport was ported to the Apify REST API (`/v2/acts/{actor}/runs` with
  `waitForFinish` + status polling, `/v2/datasets/{id}/items`), reading
  `APIFY_TOKEN` from the environment and preserving the callers' result shape
  (`runId`/`datasetId`/`itemCount`/`items`). PL's printed instructions now emit
  `apify actors call` commands. SKILL.md tables/notes and
  `data/registries.json` notes updated to match. All four scripts pass
  `python3 -m py_compile`; live runs require `APIFY_TOKEN` (not available in the
  vendoring environment) — first seeded-environment run should smoke-test one
  registry.
- **link-prospecting-outreach (owner-approved degraded mode):** upstream Step 5
  scored prospects with four Ahrefs MCP tools — a hard dependency with no CLI in
  the bundle. Per the owner's decision it ships in the skill's own documented
  degraded mode: Step 5 is skipped, authority columns and `Prospect Tier` render
  as `"-"` with a header note; the optional Ahrefs competitor auto-pull in Step 1
  is disabled. Tier scoring can return if the owner later seeds an Ahrefs REST
  key and ports Step 5. Everything else (prospect discovery, pitch angles,
  emails, placements, xlsx) is intact via REST scripts.
- **Incidental:** one comment in `data/companies.json` ("SEC EDGAR MCP + …" →
  CLI wording).

## Environment requirements

- `apify` CLI installed (environment startup script owns this if the owner adds
  it; not yet in `scripts/environment-setup.sh`).
- `APIFY_TOKEN` seeded into the environment (never committed, never pasted).
- Optional per-skill extras documented in each SKILL.md (e.g. `GUS_API_KEY` for
  PL registries, Python libs like `readability-lxml` for financial-news).

## How to update this snapshot

1. Clone both upstreams, note both `git rev-parse HEAD`s.
2. Diff each repo's skills against `plugins/archangl-apify/skills/` (expect the
   itemized strip + the financial-services hoist + the REST script ports).
3. Copy changes in, re-apply the exclusions and every itemized edit above.
4. Verify: `grep -ri mcp plugins/archangl-apify` hits only this file; all four
   registry scripts still `py_compile`; the seam tests in the repo scratch
   harness pass.
5. Update both pinned commits above and commit.
