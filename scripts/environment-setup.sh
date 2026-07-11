#!/bin/bash
set -uo pipefail

# archangl-plugin-marketplace — environment setup (drop-in)
# Thin wrapper: ensures the claude CLI and uv are reachable, then hands off to
# environment_setup.py (run with uv, stdlib-only). All real logic lives there.

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if command -v uv >/dev/null 2>&1; then
  exec uv run --script "$SCRIPT_DIR/environment_setup.py"
else
  # Fallback: any Python ≥3.9 runs the same stdlib-only script.
  log "WARN: uv unavailable — falling back to python3"
  exec python3 "$SCRIPT_DIR/environment_setup.py"
fi
