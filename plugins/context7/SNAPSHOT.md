# Vendored snapshot: context7

This plugin bundles two **Context7** (context7.com, by Upstash) skills that
drive the `ctx7` CLI. It was assembled from an owner-provided archive, not
cloned from an upstream repo — but the same snapshot rules apply: it is frozen,
must never be converted to a remote `source`, and every deviation from the
delivered content is itemized here.

| | |
| --- | --- |
| Origin | Owner-provided archive `context7skills.zip` (two skill directories: `context7-cli`, `find-docs`) |
| Upstream project | Context7 — https://context7.com (CLI: `ctx7` on npm) |
| Snapshot taken | 2026-07-10 |

## What was copied

Both skill directories verbatim into `skills/`:

- `context7-cli/` — `SKILL.md` plus `references/{docs,skills,setup}.md`: fetch
  library docs (`ctx7 library` → `ctx7 docs`), manage AI coding skills
  (`ctx7 skills …`), and setup/auth.
- `find-docs/` — `SKILL.md`: the always-check-current-docs lookup skill.

The archive contained no plugin manifest; `.claude-plugin/plugin.json` was
authored here (no `version`, per repo rule 3).

## Changes from delivered content — the MCP strip

Per the marketplace's standing no-MCP rule, Context7's MCP-server mode was
removed; the `ctx7` CLI is the only transport:

- **`context7-cli/SKILL.md`**: frontmatter description and body no longer
  mention configuring "Context7 MCP" (now "CLI + Skills mode"); the quick-ref
  setup line became `ctx7 setup --cli`.
- **`context7-cli/references/setup.md`**: rewritten CLI-only — the MCP-server
  mode bullet, `--mcp` flag, MCP-mode agent targets, `--oauth` (MCP-only)
  flag, and the "What gets written — MCP mode" section were removed; a note
  was added that the bundled `find-docs` skill makes `ctx7 setup` usually
  unnecessary here.
- `context7-cli/references/docs.md`, `references/skills.md`, and
  `find-docs/SKILL.md` are verbatim (they contained no MCP content).

## Transport contract

All operations run through the `ctx7` CLI (`npm install -g ctx7@latest`, or
`npx ctx7@latest`). Most doc-fetching commands work unauthenticated; login
(`ctx7 login`, browser OAuth) or an API key raises rate limits and enables
skill generation. Keys are seeded into the environment, never committed or
pasted into conversations. CLI installation at environment build time is owned
by the environment startup script (planned follow-up work).

## How to update this snapshot

1. Obtain the newer skill set (new archive from the owner, or the upstream
   `ctx7`-published skills).
2. Diff against `skills/` here, ignoring the itemized MCP strip above.
3. Copy changes in, re-apply the strip, update this file's table, commit.
