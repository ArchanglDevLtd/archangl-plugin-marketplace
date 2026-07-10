# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This repo is a **personal Claude Code plugin marketplace** — a single catalog that
collects the skills, agents, commands, and hooks the owner uses most and makes
them available across all of their Claude Code sessions (terminal, web, and cloud).

The distribution model is deliberate and worth internalizing before making changes:

- The **repository root is a marketplace** (`.claude-plugin/marketplace.json`).
- The marketplace **lists plugins**; each plugin lives in `plugins/<name>/`.
- Each **plugin bundles capabilities** — skills, slash commands, subagents, and/or
  hooks. (Plugins *can* also bundle MCP servers, but this marketplace bans that —
  see the standing no-MCP rule below.)

There is no "plugin inside a plugin." The three-level hierarchy is
**marketplace → plugins → capabilities**, and each level has one job. When the owner
talks about "nested plugins," the real mechanism is either (a) one marketplace listing
many plugins, or (b) plugin **dependencies** (see below) — not literal nesting.

## Repository layout

```
.claude-plugin/
  marketplace.json          # the catalog: lists every plugin in plugins/
plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json           # this plugin's manifest (name, version, dependencies)
    skills/
      <skill-name>/SKILL.md # a skill = a dir with SKILL.md
    commands/               # optional: flat .md slash commands (legacy; prefer skills)
    agents/                 # optional: subagent definitions
    hooks/hooks.json        # optional: event handlers
                            # (.mcp.json is a plugin capability Claude Code supports,
                            #  but it is BANNED here — standing no-MCP rule below)
```

## STANDING RULE: this marketplace is completely self-contained

A Claude Code session that adds this marketplace must rely **only on its connection
to this repo** — it must never be rerouted to fetch any plugin's source from anywhere
else. Concretely:

- Every entry in `marketplace.json` must use a **local** `"source": "./plugins/<name>"`
  path. Remote sources (`github`, `npm`, URLs) are **forbidden**, no exceptions.
- Third-party plugins are brought in by **vendoring a snapshot** into `plugins/<name>/`
  (full upstream tree at a pinned commit, documented in that plugin's `SNAPSHOT.md`) —
  never by referencing the upstream repo or its marketplace.
- Do not add plugin `dependencies` that resolve outside this marketplace.

## STANDING RULE: no MCP, anywhere

**No plugin in this marketplace bundles, configures, or instructs the use of MCP
servers.** Provider transport is the provider's **CLI**, authenticated by
environment variables the owner seeds into environments (never keys committed to
this repo or pasted into conversations). Concretely:

- No plugin ships a `.mcp.json` or an `mcpServers` block, ever.
- No skill, agent, command, or reference file may tell an agent to call MCP tools,
  connect connectors, or fall back to MCP when a CLI is missing — if the CLI or its
  key is absent, skills stop and surface install/seeding guidance instead.
- When vendoring a third-party plugin that ships MCP wiring, strip it as part of
  the snapshot and itemize the strip in that plugin's `SNAPSHOT.md`
  (see `plugins/nimble/SNAPSHOT.md` for the worked example).

The web-data provider is **Nimble**: the `nimble` plugin's skills run the `nimble`
CLI (`@nimble-way/nimble-cli`), which reads `NIMBLE_API_KEY` from the environment.

## Current contents

The marketplace (`name: archangl-plugin-marketplace`) lists seven plugins:

| Plugin | What it is | Notes |
| --- | --- | --- |
| `archangl-studio` | Creative production skills (currently `improve-shotlist`) | First-party |
| `archangl-search` | Research **orchestrator** — one skill, `archangl-search` (invoked as `/archangl-search:archangl-search`) | **Depends on** `nimble`; installing it auto-pulls it |
| `archangl-pocock` | **Vendored snapshot** of Matt Pocock's skills (21 engineering/productivity skills) | Frozen copy; see `plugins/archangl-pocock/SNAPSHOT.md` |
| `nimble` | **Vendored snapshot** of Nimble's agent-skills — web search/extract/map/crawl plus business-research, SEO, marketing, and productivity skills, two research agents, and a `/nimble:search` command. **CLI transport only** | Frozen copy with the MCP wiring stripped; see `plugins/nimble/SNAPSHOT.md` |
| `context7` | **Vendored snapshot** of two Context7 (Upstash) documentation skills — `context7-cli` and `find-docs`, driving the `ctx7` CLI. **CLI transport only** | Assembled from an owner-provided archive, MCP mode stripped; see `plugins/context7/SNAPSHOT.md` |
| `qmd` | **Vendored snapshot** of Tobi Lütke's qmd — local markdown search (BM25 + vector) via the `qmd` CLI, one `qmd` skill (plus upstream's `release` repo-tooling skill). **CLI transport only** | Frozen copy with the MCP transport stripped; see `plugins/qmd/SNAPSHOT.md` |
| `marketing-skills` | **Vendored snapshot** of Corey Haines' marketingskills (47 marketing skills) | Frozen copy; see `plugins/marketing-skills/SNAPSHOT.md` |

`archangl-search`'s skill deliberately does **not** run `nimble` CLI commands
directly. It routes searching/reading through the nimble plugin's own skills
(`/nimble:nimble-web-expert` by default, the vertical skills like
`/nimble:company-deep-dive` or `/nimble:seo-intel` when a sub-question matches,
and the `/nimble:search` command for quick lookups), so the provider stays
optimized for its own engine. If you touch that skill, preserve this indirection —
don't reintroduce raw CLI calls.

### Vendored (snapshot) plugins — the rule that makes this repo work

`archangl-pocock`, `nimble`, and `marketing-skills` are **snapshots**, not live
references. They were
copied from upstream at a pinned commit (recorded in each plugin's `SNAPSHOT.md`)
because the upstream repos churn and we don't want that churn changing behavior
under us — and because the standing self-containment rule above forbids remote
sources outright. Consequences to respect:

- **Never** convert these to a remote `source` (github/npm) or add the upstream
  marketplace as a dependency source. The whole point is insulation from upstream.
- Every upstream `plugin.json` had **`version` removed** (so this repo's commits
  drive updates). Any further manifest or content edits (e.g. `nimble`'s MCP strip)
  are itemized in that plugin's `SNAPSHOT.md`; keep everything else verbatim.
- To update a snapshot, do it **deliberately**: re-clone upstream, diff, copy in
  changes, re-apply the itemized edits, bump the commit/date in `SNAPSHOT.md`,
  commit. See each `SNAPSHOT.md`.
- Because `archangl-search` depends on `nimble` by **bare name** (`["nimble"]`,
  no version constraint), dependency resolution stays
  within this marketplace and needs **no git tags**. Do not add version constraints
  to that dependency unless you also start tagging releases
  (`{plugin-name}--v{version}`).

## Non-obvious rules (these cause silent failures if broken)

1. **`.claude-plugin/` holds only the manifest.** `plugin.json` (and, at the repo root,
   `marketplace.json`) are the *only* things inside `.claude-plugin/`. Every capability
   directory — `skills/`, `commands/`, `agents/`, `hooks/` — lives at the
   **plugin root**, a level *above* `.claude-plugin/`. Putting them inside
   `.claude-plugin/` makes them invisible.

2. **Relative `source` paths resolve from the marketplace root, not from
   `.claude-plugin/`.** A plugin entry with `"source": "./plugins/foo"` points to
   `<repo>/plugins/foo` even though `marketplace.json` sits in `<repo>/.claude-plugin/`.
   Never use `../` in a source path. `metadata.pluginRoot: "./plugins"` lets entries drop
   the prefix and write `"source": "foo"`.

3. **Omit `version` so updates propagate.** Claude Code resolves a plugin's version as:
   `plugin.json` version → marketplace-entry version → git commit SHA. If a static
   `version` string is set and *not* bumped, pushing new commits does **nothing** for
   existing installs — they keep the cached copy. For this actively-edited personal
   collection, leave `version` unset in both places so **every commit is a new version**.
   Only pin a `version` when intentionally freezing a plugin, and if you do, bump it on
   every release. Never set `version` in both `plugin.json` and the marketplace entry —
   `plugin.json` silently wins.

4. **Auto-update is OFF by default for third-party marketplaces.** Pushing here does not
   reach sessions until auto-update is enabled for this marketplace (per-user toggle in
   `/plugin` → Marketplaces, or `"autoUpdate": true` on the `extraKnownMarketplaces`
   entry in managed settings). Without it, updates arrive only on a manual
   `/plugin marketplace update`.

5. **Plugins are copied to a cache on install (`~/.claude/plugins/cache`).** A plugin
   cannot reference files outside its own directory (no `../shared-utils`). To share
   files between plugins, use symlinks inside each plugin, or duplicate.

6. **Plugin skills are namespaced.** A skill `review` in plugin `quality` is invoked as
   `/quality:review`, not `/review`. Standalone skills (outside a plugin) use the bare
   name. Keep this in mind when naming.

7. **Dependencies are real but require git tags.** A `plugin.json` may declare
   `"dependencies": ["other-plugin", {"name": "x", "version": "~2.1.0"}]`, and installing
   a plugin auto-installs/enables its dependencies. Version resolution reads git tags
   named `{plugin-name}--v{version}` (created with `claude plugin tag --push`). For a
   personal collection, prefer listing plugins independently in the marketplace over
   wiring dependencies — reach for dependencies only when one plugin genuinely cannot
   function without another.

## Common commands

```bash
# Validate the whole marketplace (schema, duplicate names, source path traversal)
claude plugin validate .

# Validate a single plugin (also checks SKILL.md / agent / hook frontmatter)
claude plugin validate ./plugins/<plugin-name>

# Local dev loop: add this repo as a marketplace, install a plugin, test
/plugin marketplace add .
/plugin install <plugin-name>@<marketplace-name>
/reload-plugins                       # apply install/enable/disable without restart

# After editing marketplace.json or plugin contents
/plugin marketplace update <marketplace-name>

# Tag a plugin release (only needed if using dependency version constraints)
claude plugin tag --push
```

`<marketplace-name>` is the `name` field inside `marketplace.json`, not the repo name.

## Adding a plugin or skill

- **New plugin:** create `plugins/<name>/.claude-plugin/plugin.json` (`name` +
  `description`, no `version`), add its capability dirs at the plugin root, then add an
  entry to `marketplace.json`'s `plugins` array with a `name` and
  `"source": "./plugins/<name>"`. Run `claude plugin validate .`.
- **Third-party plugin:** never reference the upstream repo as a `source` (standing
  self-containment rule). Vendor a snapshot: clone upstream, copy the full tree into
  `plugins/<name>/` (minus `.git` and any upstream `.claude-plugin/marketplace.json`),
  remove `version` from its `plugin.json`, write a `SNAPSHOT.md` recording the pinned
  commit (mirror an existing one), then add the local-source marketplace entry.
- **New skill in an existing plugin:** create
  `plugins/<plugin>/skills/<skill>/SKILL.md` with YAML frontmatter (`description` is
  what makes a skill auto-invocable; add `disable-model-invocation: true` for
  manual-only `/`-commands). No marketplace edit is needed — the plugin's `skills/`
  directory is scanned automatically.
- Keep plugin and skill `name` values **kebab-case** (the claude.ai marketplace sync
  rejects other forms).

## How distribution works (why the structure matters)

The owner adds this marketplace once at **user scope** on their account; from then on the
plugins they enable are available in every session, and (with auto-update on) each push
to this repo propagates on the next session start. That guarantee only holds if
`marketplace.json` and every `plugin.json` stay valid — a schema error or a mis-placed
capability directory silently drops the affected plugin. Run `claude plugin validate .`
before pushing.
