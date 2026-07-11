# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""archangl-plugin-marketplace — environment setup (uv script).

Invoked by the thin wrapper scripts/environment-setup.sh via `uv run --script`.
Owns everything the marketplace's plugins assume is present at environment
build time: provider CLIs (this marketplace is CLI-transport only — no MCP,
anywhere), the marketplace registration kept FRESH, and every declared plugin
installed at user scope. Idempotent; never fails the build (always exits 0).

Stdlib only — uv needs no third-party resolution to run this.
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

# Environment keys the skills expect (warn, never fail):  var -> consumer
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
            log(f"{binary} present ({out.strip().splitlines()[0] if out.strip() else 'version unknown'})")
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
