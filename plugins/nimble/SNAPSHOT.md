# Vendored snapshot: nimble

This plugin is a **frozen copy** of Nimble's official agent-skills repository,
vendored into this marketplace on purpose so that installing from this marketplace
never reaches out to any repo other than this one, and so upstream churn cannot
change behavior under us. It is **not** sourced live from the upstream repo, and
must never be converted to a remote `source` or a dependency on the upstream
marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/Nimbleway/agent-skills |
| Snapshot commit | `fdd3d17713f591b2643d90c35f44546f97458163` |
| Commit subject | `Merge pull request #51 from rome-cyber/feat/launch-monitor` |
| Commit date | 2026-06-29 |
| Snapshot taken | 2026-07-10 |
| Upstream version at snapshot | 0.25.0 |

## What was copied

The upstream repository tree: all 16 skills across 8 verticals
(`web-search-tools`, `business-research`, `marketing`, `seo`, `productivity`,
`healthcare`, `human-resources`, `data-platforms`), the two agents
(`nimble-researcher`, `nimble-analyst`), the `/nimble:search` command, `_shared/`
canonical references plus their per-skill synced copies, `scripts/sync-shared.sh`,
upstream `README.md`, `CLAUDE.md`, `AUTH.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
`.env.example`, `.gitignore`, and `LICENSE` (MIT, © Nimble — retained for
attribution).

Excluded during the copy:

- `.git/` — upstream history (the snapshot pins by the SHA above).
- `.claude-plugin/marketplace.json` — upstream's own single-plugin marketplace
  manifest. This repo's root marketplace lists the plugin instead (repo rule 1).
- `.mcp.json` and `mcp.json` — upstream's MCP server configs (see below).
- `.cursor-plugin/` — Cursor's plugin manifest, which exists to wire Cursor's MCP
  client.
- `.DS_Store` — macOS filesystem cruft.

## Changes from upstream — the MCP strip

**This snapshot deliberately deviates from verbatim fidelity for one systematic
transformation: MCP was removed as a transport. The `nimble` CLI (authenticated by
the `NIMBLE_API_KEY` environment variable the owner seeds into environments) is
the only transport.** Per the marketplace's standing rule, no plugin here bundles,
configures, or instructs the use of MCP servers.

Itemized:

- **`plugin.json`**: `version` removed (was `0.25.0`; repo rule 3 — this repo's
  commits drive updates) and the `"mcp"` keyword removed. All other fields verbatim.
- **`.mcp.json` / `mcp.json` / `.cursor-plugin/`**: excluded outright (above).
- **`_shared/nimble-playbook.md`**: the CLI-or-MCP "Transport selection" decision
  table collapsed to a CLI-only preflight (`nimble --version` + `NIMBLE_API_KEY`);
  the Cowork/claude.ai connector-connection and OAuth-authorize sections removed;
  the "MCP Fallback" section replaced with a stop-and-install rule; the MCP
  client-source caveat removed.
- **`_shared/profile-and-onboarding.md`**: onboarding collapsed to the CLI install
  + key-seeding path; plugin-connector and manual-`mcp.json` paths removed.
- **`_shared/memory-and-distribution.md`**: report distribution reworded from "MCP
  connectors" to session integrations (Notion/Slack tools), no behavior change.
- **Per-skill `references/` copies of the above**: regenerated with upstream's own
  `scripts/sync-shared.sh`, so they match the edited masters byte-for-byte.
- **All business/vertical `SKILL.md` files and `seo-intel` workflow references**:
  the boilerplate "pick CLI or MCP at session start" preflight line now reads
  CLI-only; the "MCP path: not yet supported" trailer removed; `meeting-prep`'s
  "calendar MCP tool" became "calendar tool".
- **`skills/web-search-tools/nimble-web-expert/`**: MCP tool allowlist removed from
  frontmatter; prerequisites, core principles, and `rules/setup.md` rewritten
  CLI-only; the optional "Nimble Docs MCP" replaced with CLI-based docs extraction.
- **`skills/web-search-tools/nimble-agent-builder/`**: MCP tool allowlist removed
  from frontmatter; prerequisites and Task-agent command blocks rewritten CLI-only;
  `rules/setup.md` and `rules/nimble-agent-builder.mdc` rewritten CLI-only; the
  "MCP tools" section of `references/agent-api-reference.md` deleted; MCP fallback
  tables in `references/generate-update-and-publish.md` removed.
- **`marketing/*/references/sources.md`**: transport-agnostic CLI/MCP wording
  collapsed to CLI-only.
- **`launch-monitor` sample data**: illustrative example URLs and a DOM id in
  `references/template.html` that happened to contain the string "mcp" were renamed
  (cosmetic, keeps the tree greppably MCP-free).
- **`AUTH.md`**: the "Nimble MCP server" shortcut and the "MCP server's
  environment" key-discovery step removed.
- **`README.md`**: install section now points at this marketplace
  (`/plugin install nimble@archangl-plugin-marketplace`) with CLI-only wording; the
  MCP rows/paths removed from the platform-compatibility table.
- **`CLAUDE.md` (upstream's)**: references to the excluded `.cursor-plugin/` and
  upstream `marketplace.json` removed; publishing section adapted to
  snapshot/no-version reality.
- **`CHANGELOG.md`**: untouched — historical record, exempt from the strip.

## How to update this snapshot

1. `git clone https://github.com/Nimbleway/agent-skills` somewhere outside this
   repo and note `git rev-parse HEAD`.
2. Diff against `plugins/nimble/` — expect noise from the MCP strip above; the
   itemized list is the re-apply checklist.
3. Copy upstream changes in, re-apply the exclusions and the MCP strip (edit
   `_shared/` masters first, then run `scripts/sync-shared.sh`).
4. Verify: no `.mcp.json`/`mcp.json`/`.cursor-plugin`, and a case-insensitive
   grep for "mcp" over the tree hits only `CHANGELOG.md`.
5. Update the commit/date table above (including the upstream version row) and
   commit.
