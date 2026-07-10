# Vendored snapshot: marketing-skills

This plugin is a **frozen, verbatim copy** of Corey Haines' `marketingskills`
repository, vendored into this marketplace on purpose so that installing from this
marketplace never reaches out to any repo other than this one, and so upstream churn
cannot change behavior under us. It is **not** sourced live from the upstream repo,
and must never be converted to a remote `source` or a dependency on the upstream
marketplace.

| | |
| --- | --- |
| Upstream repo | https://github.com/coreyhaines31/marketingskills |
| Snapshot commit | `f04556d923e076a29564559101e5ca33698422f5` |
| Commit subject | `Merge pull request #429 from coreyhaines31/development` |
| Commit date | 2026-07-09 |
| Snapshot taken | 2026-07-10 |
| Upstream version at snapshot | 2.8.6 |

## What was copied

The entire upstream repository tree verbatim: all **47 skills** under `skills/`
(CRO, copywriting, cold email, SEO, AI SEO, paid ads, ad creative, pricing,
referrals, revenue operations, and more), the `tools/` tree (`clis/`, `composio/`,
`integrations/`, `REGISTRY.md`), upstream `README.md`, `CLAUDE.md`, `AGENTS.md`,
`CONTRIBUTING.md`, `VERSIONS.md`, validation scripts
(`validate-skills.sh`, `validate-skills-official.sh`), `.gitignore`, `.github/`,
and `LICENSE` (MIT, © Corey Haines — retained for attribution).

The upstream `.github/workflows/` were copied for verbatim fidelity but are
**inert** here: GitHub only runs workflows from the repository root
`.github/workflows/`, never from a subdirectory. Likewise the upstream `CLAUDE.md`
inside this plugin directory is not loaded as project memory by sessions working in
this repo.

Excluded during the copy:

- `.git/` — upstream history (the snapshot pins by the SHA above).
- `.claude-plugin/marketplace.json` — upstream's own single-plugin marketplace
  manifest (`name: marketingskills`). This repo's root marketplace lists the plugin
  instead, and `.claude-plugin/` here holds only `plugin.json` (repo rule 1).
- `.DS_Store` — macOS filesystem cruft.

## Changes from upstream

- **`plugin.json` `version` (was `2.8.6`) was removed** so this repo's commits drive
  updates (repo rule 3). Every other manifest field is verbatim, including
  `"skills": "./skills"`.

## How to update this snapshot

1. `git clone https://github.com/coreyhaines31/marketingskills` somewhere outside
   this repo and note `git rev-parse HEAD`.
2. Diff against `plugins/marketing-skills/` (ignoring `.git`,
   `.claude-plugin/marketplace.json`, and the removed `version` field).
3. Copy changes in, keeping the exclusions and the `version` removal.
4. Update the commit/date table above (including the upstream version row) and
   commit.
