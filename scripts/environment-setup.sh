#!/bin/bash
set -uo pipefail

# archangl-plugin-marketplace — environment setup (drop-in)
# Runs at environment build time. Owns everything the marketplace's plugins
# assume is already present: provider CLIs (this marketplace is CLI-transport
# only — no MCP, anywhere), the marketplace registration kept FRESH, and every
# declared plugin installed at user scope. Idempotent; never fails the build.

log() { echo "[setup] $*" >&2; }

# Make the claude CLI reachable even from a bare setup shell.
command -v claude >/dev/null 2>&1 || export PATH="/opt/node22/bin:$PATH"

# ── ⬇ YOUR MARKETPLACE REPO — put the URL here ⬇ ───────────────────
#    Accepts: owner/repo  |  https://github.com/owner/repo  |  ./path
MARKETPLACE_URL="https://github.com/ArchanglDevLtd/archangl-plugin-marketplace"

# 1) Provider CLIs the plugins drive (idempotent — skip if present).
#      nimble → nimble plugin + archangl-search + archangl-studio lead-intelligence
#      ctx7   → context7 plugin
#      qmd    → qmd plugin
#      codex  → codex plugin
install_cli() { # <binary> <npm package>
  if command -v "$1" >/dev/null 2>&1; then
    log "$1 present ($("$1" --version 2>/dev/null | head -1))"
  else
    log "installing $1 ($2)"
    npm install -g "$2" >/dev/null 2>&1 || log "WARN: install of $2 failed — $1 unavailable"
  fi
}
install_cli nimble "@nimble-way/nimble-cli"
install_cli ctx7   "ctx7@latest"
install_cli qmd    "@tobilu/qmd"
install_cli codex  "@openai/codex"

# 2) Key sanity — warn, never fail. Keys are seeded into the environment,
#    never committed or pasted into sessions.
[ -n "${NIMBLE_API_KEY:-}" ] || log "WARN: NIMBLE_API_KEY not seeded — nimble skills stop at preflight"

# 3) Register the marketplace (idempotent). Claude clones it using the
#    session's git credentials, so private repos work too.
claude plugin marketplace add "$MARKETPLACE_URL" 2>/dev/null || true

# 4) Refresh every configured marketplace, then install every plugin its
#    manifest declares. The refresh matters: `add` no-ops when the
#    marketplace is already registered, and auto-update is OFF by default
#    for third-party marketplaces — without it, a reused environment keeps
#    serving a stale copy of the catalog.
total=0
while IFS=$'\t' read -r name loc; do
  [ -z "${name:-}" ] && continue
  claude plugin marketplace update "$name" >/dev/null 2>&1 || true
  manifest="$loc/.claude-plugin/marketplace.json"
  [ -f "$manifest" ] || continue
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    claude plugin install "${p}@${name}" --scope user 2>/dev/null || true
    total=$((total + 1))
  done < <(jq -r '.plugins[].name // empty' "$manifest")
done < <(claude plugin marketplace list --json 2>/dev/null \
          | jq -r '.[] | [.name, (.installLocation // .path)] | @tsv')

log "installed/enabled $total plugin(s)"
