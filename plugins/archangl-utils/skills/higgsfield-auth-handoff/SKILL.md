---
name: higgsfield-auth-handoff
description: Securely hand off Higgsfield CLI credentials from the owner's local machine to this session so the session's higgsfield CLI is authenticated. Use when the user wants to authenticate higgsfield here, says "higgsfield auth", "get higgsfield running", "higgsfield token handoff", or the higgsfield CLI reports it is not logged in. Assumes the owner has recently run `higgsfield auth login` on their local machine.
---

# Higgsfield Auth Handoff

Move a working Higgsfield login from the owner's machine into this session in
three steps: give them one copy-pasteable command, receive the file they
attach, install it where the CLI looks — **without ever reading it**.

## Security rules (absolute)

- The credentials file and everything in it is a **secret**. Never open it with
  Read, `cat`, `head`, `less`, `grep`, `jq`, or anything else that puts its
  contents into context or output. Copy it byte-for-byte with `cp` only.
- Never run a command that prints the token (`higgsfield auth token` writes the
  access token to stdout — if you run it to verify, redirect stdout to
  `/dev/null`).
- If the contents ever end up in context or in a transcript by accident, say so
  immediately and tell the owner to re-run `higgsfield auth login` locally to
  rotate.

## Step 1 — Give the owner the export command

Present exactly one copy-pasteable command for their **local** terminal (works
on macOS and Linux; assumes a recent `higgsfield auth login` there):

```bash
f="$HOME/higgsfield_token_$(date +%y%m%d-%H%M).json"; higgsfield auth token >/dev/null && cp "$(ls -t "${XDG_CONFIG_HOME:-$HOME/.config}/higgsfield/credentials.json" "$HOME/Library/Application Support/higgsfield/credentials.json" 2>/dev/null | head -n1)" "$f" && echo "Now attach this file to the chat: $f"
```

What it does, in order: refreshes/validates the session (`higgsfield auth
token`, output discarded), finds `credentials.json` in the CLI's config dir
(XDG path on Linux, Application Support on macOS), and copies it to their home
directory as `higgsfield_token_<short-timestamp-slug>.json` so it's easy to
find and attach. If the command errors, the likely cause is a stale login —
ask them to run `higgsfield auth login` first, then retry.

## Step 2 — Ask for the file

Ask the owner to attach the generated `higgsfield_token_*.json` to the chat.
Do nothing else until it arrives.

## Step 3 — Install it (copy only, never read)

Uploaded files land on disk (commonly under `/root/.claude/uploads/…`); the
message that delivers the attachment includes its path. Then:

```bash
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/higgsfield"
cp "<uploaded-file-path>" "${XDG_CONFIG_HOME:-$HOME/.config}/higgsfield/credentials.json"
chmod 600 "${XDG_CONFIG_HOME:-$HOME/.config}/higgsfield/credentials.json"
```

If the `higgsfield` CLI is not installed in the session yet, install it first:
`npm install -g @higgsfield/cli`.

## Step 4 — Verify silently, then clean up

```bash
higgsfield auth status            # prints login state, not the token
higgsfield auth token >/dev/null && echo "higgsfield CLI: authenticated"
rm -f "<uploaded-file-path>"      # remove the loose copy from the uploads dir
```

Report only "authenticated" or the failure state — never token material.
Suggest the owner also delete the `higgsfield_token_*.json` from their local
home directory once the session confirms auth.
