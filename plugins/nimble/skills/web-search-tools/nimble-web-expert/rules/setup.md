---
description: One-time setup instructions for Nimble — CLI install + API key. Load this only when the quick check in SKILL.md fails.
alwaysApply: false
---

# Nimble Setup

The `nimble` CLI is the only transport. Setup is two steps: install the CLI,
seed `NIMBLE_API_KEY` into the environment.

---

## 1. CLI install

### One-time init (run once per machine)

Saves the API key to `~/.claude/settings.json` so Claude Code auto-injects it every session — no exports needed.

```bash
python3 -c "
import json, pathlib, subprocess, os

p = pathlib.Path.home() / '.claude/settings.json'
d = json.loads(p.read_text()) if p.exists() else {}
env = d.setdefault('env', {})

# Verify nimble is installed
try:
    r = subprocess.run(['nimble', '--version'], capture_output=True, text=True, timeout=5)
    if r.returncode == 0:
        print('✓ nimble: ' + r.stdout.strip())
    else:
        raise Exception('non-zero exit')
except:
    print('✗ nimble not found — install it first:')
    print('    npm i -g @nimble-way/nimble-cli')
    exit(1)

# Save API key
key = env.get('NIMBLE_API_KEY') or os.environ.get('NIMBLE_API_KEY', '')
if key and not env.get('NIMBLE_API_KEY'):
    env['NIMBLE_API_KEY'] = key
    print('✓ Saved NIMBLE_API_KEY to ~/.claude/settings.json')
print('NIMBLE_API_KEY: ' + ('set' if key else 'MISSING — see API key setup below'))
p.write_text(json.dumps(d, indent=2))
if key:
    print()
    print('✓ Init complete. Restart Claude Code to activate.')
"
```

**After running init → restart Claude Code.** The key is auto-injected from that point on.

---

## Install nimble CLI

```bash
npm i -g @nimble-way/nimble-cli
```

Then re-run the init script above.

---

## Set up API key

In managed/cloud environments, `NIMBLE_API_KEY` is seeded by the environment's
startup configuration — if it's missing there, ask the owner to seed it rather
than pasting a key into the session. For a local machine:

**Step 1 — Open the Nimble dashboard:**

```bash
open -a "Google Chrome" "https://online.nimbleway.com/overview" 2>/dev/null || open "https://online.nimbleway.com/overview"
```

Go to **Overview → API Token**, copy your token, and paste it when prompted.

**Step 2 — Save permanently + activate now:**

Replace `<TOKEN>` with the pasted value:

```bash
export NIMBLE_API_KEY="<TOKEN>"
python3 -c "
import json, pathlib
key = '<TOKEN>'
p = pathlib.Path.home() / '.claude/settings.json'
d = json.loads(p.read_text()) if p.exists() else {}
d.setdefault('env', {})['NIMBLE_API_KEY'] = key
p.write_text(json.dumps(d, indent=2))
print('✓ Saved to ~/.claude/settings.json')
"
```

⚠️ **After this point: never prepend `export NIMBLE_API_KEY=...` to any subsequent command.** The key is in the environment. Just run `nimble ...` directly.

---

## Nimble docs access

Pull the docs with the CLI itself when you need CLI flags, agent schemas, or API
reference:

```bash
# Compact overview
nimble --transform "data.markdown" extract \
  --url "https://docs.nimbleway.com/llms.txt" --format markdown

# Full documentation
nimble --transform "data.markdown" extract \
  --url "https://docs.nimbleway.com/llms-full.txt" --format markdown > .nimble/nimble-docs-full.md
head -200 .nimble/nimble-docs-full.md
```
