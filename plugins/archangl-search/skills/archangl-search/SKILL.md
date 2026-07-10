---
name: archangl-search
description: Multi-source research using the Nimble provider skills. Searches the web, synthesizes findings, and delivers cited reports with source attribution. Use when the user wants thorough research on any topic with evidence and citations.
metadata:
  origin: ECC
---

# Archangl Search

> **Routes through provider skills.** This skill orchestrates; it does not run
> raw `nimble` commands or call the Nimble API directly. It delegates searching
> and reading to the `nimble` plugin — installed automatically as a dependency
> of `archangl-search` — so the provider's own skills stay optimized as flags,
> quotas, and result shapes drift. Verify the `nimble` plugin is installed before
> promising coverage or quoting live source counts.

Produce thorough, cited research reports from multiple web sources by orchestrating the Nimble provider skills.

## When to Activate

- User asks to research any topic in depth
- Competitive analysis, technology evaluation, or market sizing
- Due diligence on companies, investors, or technologies
- Any question requiring synthesis from multiple sources
- User says "research", "investigate", "dig into", or "what's the current state of"

## Provider Skills

The actual searching and reading is done **through the nimble plugin's own skills**,
each tuned for the Nimble engine. Do not run raw `nimble` commands or call the Nimble
API from here — invoke the skills so each stays optimized for its own behavior. The
`nimble` plugin is pulled in automatically as a dependency of `archangl-search`:

- **General search / fetch / crawl** → `/nimble:nimble-web-expert` — Nimble's core
  web-data skill (search with 8 focus modes, URL extraction, site mapping, bulk
  crawling). This is the default dispatch target for research sub-questions.
- **Domain sub-questions** → Nimble's specialist skills when a sub-question matches
  their vertical: `/nimble:company-deep-dive`, `/nimble:competitor-intel`, and
  `/nimble:market-finder` (business research), `/nimble:seo-intel` (SEO), or the
  marketing/productivity skills (`/nimble:brand-mention-monitor`,
  `/nimble:meeting-prep`, …).
- **Quick single lookup** → the `/nimble:search <query>` command when a sub-question
  needs one fast search rather than a full skill dispatch.

Vary focus modes (general, news, academic, social) across dispatches for coverage —
different modes surface different sources.

**Transport is the Nimble CLI, nothing else.** Downstream, every nimble skill reaches
its engine through the `nimble` CLI, authenticated by the `NIMBLE_API_KEY`
environment variable seeded into the environment (the key never lives in this repo
and is never pasted into a conversation). If the CLI or key is missing, report that
Nimble isn't ready — the nimble skills' own preflight prints the install/key
guidance — do not fall back to WebSearch, WebFetch, curl, or a raw API key.

## Workflow

### Step 1: Understand the Goal

Ask 1-2 quick clarifying questions:
- "What's your goal — learning, making a decision, or writing something?"
- "Any specific angle or depth you want?"

If the user says "just research it" — skip ahead with reasonable defaults.

### Step 2: Plan the Research

Break the topic into 3-5 research sub-questions. Example:
- Topic: "Impact of AI on healthcare"
  - What are the main AI applications in healthcare today?
  - What clinical outcomes have been measured?
  - What are the regulatory challenges?
  - What companies are leading this space?
  - What's the market size and growth trajectory?

### Step 3: Execute Multi-Source Search

For EACH sub-question, dispatch the nimble skills rather than running `nimble`
commands directly. Hand each skill the sub-question plus any angle/recency
constraints, and let it run its own optimized search + read:

**Default dispatch:**
```
/nimble:nimble-web-expert  — the sub-question; state recency/entity constraints and the focus mode in the prompt
```

**When a sub-question matches a vertical:**
```
/nimble:company-deep-dive | /nimble:competitor-intel | /nimble:market-finder | /nimble:seo-intel | …
```

Keep each per-sub-question dispatch scoped to a quick pass so the provider skills
stay lightweight; reserve a full specialist-skill run for a sub-question that is
itself substantial.

**Search strategy:**
- Use 2-3 different keyword variations per sub-question
- Mix focus modes: general and news for most topics; academic or social when the angle calls for it
- Aim for 15-30 unique sources total
- Prioritize: academic, official, reputable news > blogs > forums
- Dedupe sources that multiple dispatches return

### Step 4: Read Key Sources in Full

The provider skills extract and read full sources as part of their own flow, so most
full reads already happen in Step 3. When you need a specific URL the skills did not
already read in full, route it back through `/nimble:nimble-web-expert` (it fetches
and reads full page content from any URL) rather than running an extract command
directly.

Read 3-5 key sources in full for depth. Do not rely only on search snippets.

### Step 5: Synthesize and Write Report

Structure the report:

```markdown
# [Topic]: Research Report
*Generated: [date] | Sources: [N] | Confidence: [High/Medium/Low]*

## Executive Summary
[3-5 sentence overview of key findings]

## 1. [First Major Theme]
[Findings with inline citations]
- Key point ([Source Name](url))
- Supporting data ([Source Name](url))

## 2. [Second Major Theme]
...

## 3. [Third Major Theme]
...

## Key Takeaways
- [Actionable insight 1]
- [Actionable insight 2]
- [Actionable insight 3]

## Sources
1. [Title](url) — [one-line summary]
2. ...

## Methodology
Searched [N] queries across web and news. Analyzed [M] sources.
Sub-questions investigated: [list]
```

### Step 6: Deliver

- **Short topics**: Post the full report in chat
- **Long reports**: Post the executive summary + key takeaways, save full report to a file

## Parallel Research with Subagents

For broad topics, use Claude Code's Task tool to parallelize:

```
Launch 3 research agents in parallel:
1. Agent 1: Research sub-questions 1-2
2. Agent 2: Research sub-questions 3-4
3. Agent 3: Research sub-question 5 + cross-cutting themes
```

Each agent dispatches the provider skills, reads sources, and returns findings. The main session synthesizes into the final report.

## Quality Rules

1. **Every claim needs a source.** No unsourced assertions.
2. **Cross-reference.** If only one source says it, flag it as unverified.
3. **Recency matters.** Prefer sources from the last 12 months.
4. **Acknowledge gaps.** If you couldn't find good info on a sub-question, say so.
5. **No hallucination.** If you don't know, say "insufficient data found."
6. **Separate fact from inference.** Label estimates, projections, and opinions clearly.

## Examples

```
"Research the current state of nuclear fusion energy"
"Investigate Rust vs Go for backend services in 2026"
"Research the best strategies for bootstrapping a SaaS business"
"What's happening with the US housing market right now?"
"Investigate the competitive landscape for AI code editors"
```
