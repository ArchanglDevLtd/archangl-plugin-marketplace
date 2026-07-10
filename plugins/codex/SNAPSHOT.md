# Vendored snapshot: codex

This plugin is a **frozen copy** of OpenAI's Codex plugin for Claude Code,
vendored into this marketplace on purpose so that installing from this
marketplace never reaches out to any repo other than this one. It replaces the
earlier marketplace entry that sourced this plugin **live** via `git-subdir`
from the upstream repo — that entry violated the standing self-containment
rule and was converted to this snapshot at merge time. It must never be
converted back to a remote `source`.

| | |
| --- | --- |
| Upstream repo | https://github.com/openai/codex-plugin-cc (subtree `plugins/codex`) |
| Snapshot commit | `db52e28f4d9ded852ab3942cea316258ae4ef346` |
| Commit subject | `Remove shell expansion for git commands (#447)` |
| Commit date | 2026-07-07 |
| Snapshot taken | 2026-07-10 |
| Upstream version at snapshot | 1.0.6 |

## What was copied

The upstream `plugins/codex` subtree verbatim: eight commands (`review`,
`adversarial-review`, `rescue`, `result`, `status`, `setup`, `transfer`,
`cancel`), three skills (`codex-cli-runtime`, `codex-result-handling`,
`gpt-5-4-prompting`), the `codex-rescue` agent, `hooks/hooks.json` plus the
lifecycle/review-gate hook scripts, the `scripts/` app-server broker and
libraries, `prompts/`, `schemas/`, `CHANGELOG.md`, `NOTICE`, and `LICENSE`
(Apache-2.0, © OpenAI — retained for attribution).

## Changes from upstream

- **`plugin.json` `version` (was `1.0.6`) was removed** so this repo's commits
  drive updates (repo rule 3). Every other manifest field is verbatim.
- **Model-guidance override (owner request, 2026-07-10):** each of the three
  skills carries an owner override block at the top of its `SKILL.md` — agents
  must ask the owner which Codex model to use and recommend from a grounded
  evaluation of the current model family plus a reasoning-effort level — and
  model references in skill content were moved from GPT-5.4 semantics to the
  GPT-5.6 family. The `gpt-5-4-prompting` skill directory/name is kept (renaming
  would change the skill's invocation name); its content and override carry the
  5.6 semantics.
- **No MCP strip was needed**: the plugin bundles no `.mcp.json` and no
  `mcpServers` block. `scripts/lib/codex.mjs` contains `mcpToolCall` protocol
  handling and passes an empty `mcpServers` list to the Codex app-server —
  program source kept verbatim (same decision as `qmd`'s `src/`); no
  agent-facing file instructs MCP use.

## Transport contract

The plugin drives the `codex` CLI (and its app-server protocol) via bundled
scripts. CLI installation/auth at environment build time is owned by the
environment startup script (planned follow-up work).

## How to update this snapshot

1. `git clone https://github.com/openai/codex-plugin-cc` outside this repo and
   note `git rev-parse HEAD`.
2. Diff its `plugins/codex` subtree against `plugins/codex/` here (ignoring the
   removed `version`, the model-guidance overrides, and the 5.6 model swap).
3. Copy changes in, re-apply the itemized edits, update the table above, commit.
