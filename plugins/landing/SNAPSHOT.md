# Vendored snapshot: landing

This plugin is a **frozen copy** of the `marketing/landing` plugin from Alireza
Rezvani's claude-skills monorepo — a premium single-file HTML landing page
generator (one `landing` skill with three reference docs and three stdlib
Python validators, a `cs-landing` subagent, and a `/landing:cs-landing`
command). It is not a live reference: it must never be converted to a remote
`source`, and every deviation from upstream is itemized here.

| | |
| --- | --- |
| Upstream repo | https://github.com/alirezarezvani/claude-skills |
| Upstream path | `marketing/landing/` (the rest of the monorepo was not copied) |
| Pinned commit | `0241f43765572f15146fcef692defbf96d473f37` (upstream `main`, 2026-07-07) |
| Upstream version at snapshot | 2.9.0 |
| Snapshot taken | 2026-07-12 |
| License | MIT |

## What was copied

The full `marketing/landing/` subtree, verbatim:

- `.claude-plugin/plugin.json` — manifest (edited; see below)
- `README.md`
- `skills/landing/` — `SKILL.md`, `references/{brand_system_design,gsap_animation_patterns,single_file_html_discipline}.md`,
  `scripts/{brand_palette_validator,kebab_slug_generator,html_validator}.py`
  (all three scripts are Python stdlib only — no network, no external deps)
- `agents/cs-landing.md`
- `commands/cs-landing.md`

## Changes from upstream

- **`.claude-plugin/plugin.json`: removed `"version": "2.9.0"`** (repo rule 3 —
  this marketplace leaves `version` unset so every commit propagates to
  installs). Everything else in the manifest is verbatim, including upstream's
  informational `skills`/`source` fields.
- **No MCP strip was needed.** Upstream ships no `.mcp.json`, no `mcpServers`
  block, and no skill/agent/command text referencing MCP — the plugin already
  complies with the standing no-MCP rule. The only external runtime
  dependencies are the generated pages' CDN links (Google Fonts + GSAP), which
  live in the HTML output, not in the plugin's transport.

## Known dead links (left verbatim)

Upstream is a monorepo, and some **documentation links** point outside the
copied subtree; they are prose/citation only — nothing functional resolves
through them, so they were kept verbatim rather than rewritten:

- `README.md`, `SKILL.md`, `agents/cs-landing.md`, `commands/cs-landing.md`
  link to the source spec `megaprompts/04-landing-megaprompt.md` and mention
  `/cs:grill-with-docs`, `product-team/skills/landing-page-generator/`, and
  sibling agents (`cs-capture`, `cs-pulse`) — none of which exist in this
  marketplace.
- Upstream namespaces the command as `/cs:landing`; here the plugin name is
  `landing`, so it is invoked as `/landing:cs-landing` (the skill as
  `/landing:landing`).

All `../` paths used *functionally* (agent/command → `skills/landing/scripts`,
`skills/landing/references`) stay inside this plugin's directory and work as-is.

## How to update this snapshot

1. `git clone https://github.com/alirezarezvani/claude-skills` and diff its
   `marketing/landing/` against this directory, ignoring the itemized edits
   above.
2. Copy changes in, re-apply the edits (drop `version` from `plugin.json`),
   and confirm upstream hasn't introduced MCP wiring — strip and itemize it
   here if it has.
3. Update the pinned commit/date table above, run `claude plugin validate .`,
   commit.
