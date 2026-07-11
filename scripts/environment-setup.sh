#!/bin/bash
set -uo pipefail

# archangl-plugin-marketplace — environment setup (single-file drop-in)
# Thin bash wrapper around an embedded Python script run with uv. Everything is
# in THIS one file so it can be pasted directly into an environment's startup
# script field (no companion files needed). Idempotent; never fails the build.

log() { echo "[setup] $*" >&2; }

# Make the claude CLI reachable even from a bare setup shell.
command -v claude >/dev/null 2>&1 || export PATH="/opt/node22/bin:$PATH"

# Ensure uv (installs to ~/.local/bin when missing; never fails the build).
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  log "installing uv"
  curl -LsSf https://astral.sh/uv/install.sh 2>/dev/null | sh >/dev/null 2>&1 \
    || log "WARN: uv install failed"
fi

# Materialize the embedded Python (PEP 723, stdlib-only) to a temp file.
PY_FILE="$(mktemp -t env-setup-XXXXXX.py)"
trap 'rm -f "$PY_FILE"' EXIT
cat > "$PY_FILE" <<'PYEOF'
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""archangl-plugin-marketplace — environment setup (embedded uv script).

Owns everything the marketplace's plugins assume is present at environment
build time: provider CLIs (this marketplace is CLI-transport only — no MCP,
anywhere), the marketplace registration kept FRESH, and every declared plugin
installed at user scope. Idempotent; never fails the build (always exits 0).
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

# ── ⬇ YOUR MARKETPLACE REPO — put the URL here ⬇ ───────────────────
#    Accepts: owner/repo  |  https://github.com/owner/repo  |  ./path
MARKETPLACE_URL = "https://github.com/ArchanglDevLtd/archangl-plugin-marketplace"

# Provider CLIs the plugins drive:  binary -> npm package
#   nimble → nimble plugin + archangl-search + archangl-studio lead-intelligence
#   ctx7   → context7 plugin
#   qmd    → qmd plugin
#   codex  → codex plugin
#   apify  → archangl-apify plugin
CLIS = {
    "nimble": "@nimble-way/nimble-cli",
    "ctx7": "ctx7@latest",
    "qmd": "@tobilu/qmd",
    "codex": "@openai/codex",
    "apify": "apify-cli",
}

# Environment keys the skills expect (warn, never fail):  var -> consequence
KEYS = {
    "NIMBLE_API_KEY": "nimble skills stop at preflight",
    "APIFY_TOKEN": "archangl-apify skills stop at preflight",
}


def log(msg: str) -> None:
    print(f"[setup] {msg}", file=sys.stderr)


def run(cmd, timeout=600):
    """Run a command, never raising — returns (returncode, stdout)."""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, p.stdout
    except Exception as e:  # noqa: BLE001 — a setup script must never explode
        return 1, str(e)


def install_clis() -> None:
    for binary, package in CLIS.items():
        if shutil.which(binary):
            _, out = run([binary, "--version"], timeout=15)
            first = out.strip().splitlines()[0] if out.strip() else "version unknown"
            log(f"{binary} present ({first})")
        else:
            log(f"installing {binary} ({package})")
            rc, _ = run(["npm", "install", "-g", package])
            if rc != 0:
                log(f"WARN: install of {package} failed — {binary} unavailable")


def check_keys() -> None:
    for var, consequence in KEYS.items():
        if not os.environ.get(var):
            log(f"WARN: {var} not seeded — {consequence}")


def install_plugins() -> int:
    # Register the marketplace (idempotent). Claude clones it with the
    # session's git credentials, so private repos work too.
    run(["claude", "plugin", "marketplace", "add", MARKETPLACE_URL])

    # Refresh every configured marketplace, then install every plugin its
    # manifest declares. The refresh matters: `add` no-ops when the
    # marketplace is already registered, and auto-update is OFF by default
    # for third-party marketplaces — without it, a reused environment keeps
    # serving a stale copy of the catalog.
    total = 0
    rc, out = run(["claude", "plugin", "marketplace", "list", "--json"], timeout=120)
    if rc != 0:
        log("WARN: could not list marketplaces — no plugins installed")
        return 0
    try:
        marketplaces = json.loads(out)
    except json.JSONDecodeError:
        log("WARN: unparseable marketplace list — no plugins installed")
        return 0

    for m in marketplaces:
        name = m.get("name")
        loc = m.get("installLocation") or m.get("path")
        if not name or not loc:
            continue
        run(["claude", "plugin", "marketplace", "update", name], timeout=300)
        manifest = Path(loc) / ".claude-plugin" / "marketplace.json"
        if not manifest.is_file():
            continue
        try:
            plugins = json.loads(manifest.read_text()).get("plugins", [])
        except (OSError, json.JSONDecodeError):
            continue
        for p in plugins:
            pname = p.get("name")
            if not pname:
                continue
            run(["claude", "plugin", "install", f"{pname}@{name}", "--scope", "user"], timeout=300)
            total += 1
    return total


def main() -> int:
    install_clis()
    check_keys()
    total = install_plugins()
    log(f"installed/enabled {total} plugin(s)")
    return 0  # never fail the environment build


if __name__ == "__main__":
    sys.exit(main())
PYEOF

if command -v uv >/dev/null 2>&1; then
  uv run --script "$PY_FILE"
else
  # Fallback: any Python ≥3.9 runs the same stdlib-only script.
  log "WARN: uv unavailable — falling back to python3"
  python3 "$PY_FILE"
fi
exit 0
