# Vendored snapshot: archangl-pocock

This plugin is a **frozen, verbatim copy** of Matt Pocock's `mattpocock/skills`
repository, vendored into this marketplace on purpose so upstream churn cannot change
behavior under us. It is **not** sourced live from the upstream repo or marketplace, and
must never be converted to a remote `source` or a dependency on the upstream marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/mattpocock/skills |
| Snapshot commit | `d574778f94cf620fcc8ce741584093bc650a61d3` |
| Commit subject | `Merge pull request #353 from mattpocock/changeset-release/main` |
| Commit date | 2026-07-08 |
| Snapshot taken | 2026-07-09 |
| Source | user-provided attachment (`pocockskills.zip`), pinned verbatim |

## What was copied

The **entire upstream repository tree** was copied verbatim, so the plugin matches the
attachment exactly. This includes all 21 promoted skills declared in `plugin.json`
(`skills/engineering/*`, `skills/productivity/*`) plus the non-promoted buckets
(`skills/misc`, `skills/personal`, `skills/in-progress`, `skills/deprecated`), the
`docs/` tree, `README.md`, `LICENSE` (MIT, © Matt Pocock — retained for attribution),
the upstream `CLAUDE.md`, and upstream repo tooling (`.agents/`, `.changeset/`,
`scripts/`, `.github/`, `.out-of-scope/`).

Only these were **excluded** during the copy:

- `.git/` — the upstream git history (a snapshot pins by the SHA recorded above, not
  by carrying a nested repo).
- `.DS_Store` — macOS filesystem cruft.

The upstream `.github/workflows/release.yml` (a Changesets release workflow) was copied
for verbatim fidelity but is **inert** here: GitHub only runs workflows from the
repository root `.github/workflows/`, never from a subdirectory, so it never executes.

## Changes from upstream

- **`plugin.json` `name`** was changed from `mattpocock-skills` to `archangl-pocock`
  so this plugin is listed and namespaced under the archangl brand (matching the
  marketplace entry). Its skills are therefore invoked as `/archangl-pocock:<skill>`
  (e.g. `/archangl-pocock:ask-matt`, `/archangl-pocock:tdd`). Everything else in the
  manifest — including the full `skills` array — is verbatim.
- No `version` field was present upstream and none was added, so this repo's git commit
  SHA drives versioning and propagation (see the repo-root `CLAUDE.md`).

Nothing else in the tree was modified.

## Refreshing this snapshot

Do this **deliberately**, never automatically: re-obtain upstream at the desired
commit, diff against this directory, copy in the intended changes, re-apply the two
edits above (name change; drop `.git`/`.DS_Store`), update the commit/date fields in
this file, and commit. Do not add the upstream repo as a live `source`.
