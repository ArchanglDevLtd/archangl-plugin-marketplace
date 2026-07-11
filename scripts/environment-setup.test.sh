#!/usr/bin/env bash
# Seam tests for scripts/environment-setup.sh — run before deploying the script.
# Sandbox: env -i with a fresh HOME + fresh npm prefix, exposing ONLY the
# binaries a fresh environment would have (node, npm, npx, claude). Tests the
# script's public contract, nothing internal:
#   1. exit 0 on a fresh environment (and with NIMBLE_API_KEY missing)
#   2. log contract: key warning + install summary
#   3. post-condition: nimble/ctx7/qmd/codex/apify installed into the sandbox prefix
#   4. post-condition: marketplace registered, all catalog plugins installed
#   5. idempotency: second run exits 0 and skips CLI reinstalls
set -u
SCRIPT="$(cd "$(dirname "$0")" && pwd)/environment-setup.sh"
NODE_BIN="${NODE_BIN:-$(dirname "$(command -v node)")}"
# EXPECTED_PLUGINS: optional override; by default derived from the manifest the sandbox fetches.
EXPECTED_PLUGINS="${EXPECTED_PLUGINS:-}"
SBX="$(mktemp -d)"
trap 'rm -rf "$SBX"' EXIT
mkdir -p "$SBX/home" "$SBX/npm" "$SBX/bin"
for b in node npm npx claude; do
  printf '#!/bin/sh\nexec %s/%s "$@"\n' "$NODE_BIN" "$b" > "$SBX/bin/$b"
  chmod +x "$SBX/bin/$b"
done
SBX_PATH="$SBX/npm/bin:$SBX/bin:/usr/bin:/bin"

run_sandboxed() { # <logfile>
  env -i \
    HOME="$SBX/home" \
    npm_config_prefix="$SBX/npm" \
    npm_config_cache="$SBX/npm-cache" \
    PATH="$SBX_PATH" \
    HTTPS_PROXY="${HTTPS_PROXY:-}" HTTP_PROXY="${HTTP_PROXY:-}" NO_PROXY="${NO_PROXY:-}" \
    NODE_EXTRA_CA_CERTS="${NODE_EXTRA_CA_CERTS:-}" SSL_CERT_FILE="${SSL_CERT_FILE:-}" \
    TERM=dumb \
    bash "$SCRIPT" >"$1" 2>&1
}

FAIL=0
t() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS: $d"; else echo "FAIL: $d"; FAIL=1; fi; }

echo "== RUN 1 (fresh sandbox, no NIMBLE_API_KEY) =="
run_sandboxed "$SBX/run1.log"; RC1=$?
t "seam 1: exit code 0 on fresh environment"        test "$RC1" -eq 0
t "seam 2: NIMBLE_API_KEY warning emitted"          grep -q 'WARN: NIMBLE_API_KEY not seeded' "$SBX/run1.log"
t "seam 2: APIFY_TOKEN warning emitted"             grep -q 'WARN: APIFY_TOKEN not seeded' "$SBX/run1.log"
t "seam 2: install summary line emitted"            grep -qE '\[setup\] installed/enabled [0-9]+ plugin\(s\)' "$SBX/run1.log"
t "seam 3: nimble CLI installed in sandbox"         test -x "$SBX/npm/bin/nimble"
t "seam 3: ctx7 CLI installed in sandbox"           test -x "$SBX/npm/bin/ctx7"
t "seam 3: qmd CLI installed in sandbox"            test -x "$SBX/npm/bin/qmd"
t "seam 3: codex CLI installed in sandbox"          test -x "$SBX/npm/bin/codex"
t "seam 3: apify CLI installed in sandbox"          test -x "$SBX/npm/bin/apify"
t "seam 4: marketplace registered in sandbox HOME"  sh -c "env -i HOME='$SBX/home' PATH='$SBX_PATH' claude plugin marketplace list 2>/dev/null | grep -qi archangl"
if [ -z "$EXPECTED_PLUGINS" ]; then
  EXPECTED_PLUGINS=$(env -i HOME="$SBX/home" PATH="$SBX_PATH" sh -c '
    loc=$(claude plugin marketplace list --json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(next((m.get(\"installLocation\") or m.get(\"path\") for m in d if \"archangl\" in m.get(\"name\",\"\")), \"\"))")
    [ -n "$loc" ] && python3 -c "import json; print(len(json.load(open(\"$loc/.claude-plugin/marketplace.json\"))[\"plugins\"]))" || echo 0')
fi
t "seam 4: all $EXPECTED_PLUGINS catalog plugins installed" sh -c "env -i HOME='$SBX/home' PATH='$SBX_PATH' claude plugin list 2>/dev/null | grep -c 'archangl-plugin-marketplace' | grep -qx $EXPECTED_PLUGINS"

echo "== RUN 2 (same sandbox — idempotency) =="
run_sandboxed "$SBX/run2.log"; RC2=$?
t "seam 5: second run exits 0"                      test "$RC2" -eq 0
t "seam 5: second run skips CLI installs"           sh -c "! grep -q 'installing nimble' '$SBX/run2.log' && grep -q 'nimble present' '$SBX/run2.log'"

echo; if [ "$FAIL" -eq 0 ]; then echo "ALL SEAMS GREEN"; else echo "SEAMS RED — run1 log:"; sed -n '1,40p' "$SBX/run1.log"; exit 1; fi
