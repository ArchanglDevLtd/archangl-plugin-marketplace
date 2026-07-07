# Vendored snapshot: firecrawl-workflows

This plugin is a **frozen copy** of an upstream third-party plugin, vendored into
this marketplace on purpose so that upstream churn cannot change behavior under us.
It is not sourced live from the upstream repo or marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/firecrawl/firecrawl-workflows |
| Snapshot commit | `1a6b302731139d6de6117d205efd8198d3775cc3` |
| Commit date | 2026-06-19 |
| Upstream `version` at snapshot | `0.1.0` |
| Snapshot taken | 2026-07-07 |

## What was copied

- `skills/` — all 16 workflow skills, verbatim
- `references/workflow-authoring.md` — referenced by `skills/firecrawl-workflows`
- `.claude-plugin/plugin.json` — see change below
- `LICENSE` — upstream ISC license, retained for attribution

Upstream build/dev files (`.git/`, `.codex-plugin/`, `.cursor-plugin/`, the repo's
own `marketplace.json`, `AGENTS.md`) were intentionally **not** copied — they are
not part of the plugin's runtime and would only add noise.

## Only change from upstream

`version` was removed from `plugin.json`. In this personal marketplace, plugin
versions are driven by the git commit SHA of *this* repo (see `CLAUDE.md`), so
every commit here propagates to installs. The upstream value (`0.1.0`) is recorded
above.

## Refreshing this snapshot

To pull a newer upstream state deliberately, re-clone the upstream repo, diff it
against this directory, copy in the changes, update the commit/date/version above,
and commit. Do this as an intentional act — never wire this plugin to update itself
from upstream.
