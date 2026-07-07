# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This repo is a **personal Claude Code plugin marketplace** — a single catalog that
collects the skills, agents, hooks, and MCP servers the owner uses most and makes
them available across all of their Claude Code sessions (terminal, web, and cloud).

The distribution model is deliberate and worth internalizing before making changes:

- The **repository root is a marketplace** (`.claude-plugin/marketplace.json`).
- The marketplace **lists plugins**; each plugin lives in `plugins/<name>/`.
- Each **plugin bundles capabilities** — skills, slash commands, subagents, hooks,
  and/or MCP servers.

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
    .mcp.json               # optional: MCP server configs
```

## Non-obvious rules (these cause silent failures if broken)

1. **`.claude-plugin/` holds only the manifest.** `plugin.json` (and, at the repo root,
   `marketplace.json`) are the *only* things inside `.claude-plugin/`. Every capability
   directory — `skills/`, `commands/`, `agents/`, `hooks/`, `.mcp.json` — lives at the
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
