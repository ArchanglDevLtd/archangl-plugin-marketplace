---
name: archangl-deep-research
description: Multi-source deep research using the Firecrawl and Exa provider skills. Searches the web, synthesizes findings, and delivers cited reports with source attribution. Use when the user wants thorough research on any topic with evidence and citations.
metadata:
  origin: ECC
---

# Deep Research

> **Routes through provider skills.** This skill orchestrates; it does not call
> Firecrawl/Exa MCP tools directly. It delegates searching and reading to the
> `firecrawl-workflows` and `exa` plugins — installed automatically as dependencies
> of `archangl-search` — so each provider's own skill stays optimized as tool names,
> quotas, and result shapes drift. Verify those two plugins are installed before
> promising coverage or quoting live source counts.

Produce thorough, cited research reports from multiple web sources by orchestrating the Firecrawl and Exa provider skills.

## When to Activate

- User asks to research any topic in depth
- Competitive analysis, technology evaluation, or market sizing
- Due diligence on companies, investors, or technologies
- Any question requiring synthesis from multiple sources
- User says "research", "deep dive", "investigate", or "what's the current state of"

## Provider Skills

The actual searching and reading is done **through the provider plugins' own skills**,
each tuned for its engine. Do not call raw provider MCP tools from here — invoke the
skills so each stays optimized for its own behavior. Both plugins are pulled in
automatically as dependencies of `archangl-search`:

- **Firecrawl** → `/firecrawl-workflows:firecrawl-deep-research` — Firecrawl's own
  cited-report research skill (search + scrape + synthesis, optimized for Firecrawl).
  Other Firecrawl skills (`firecrawl-market-research`, `firecrawl-competitive-intel`,
  `firecrawl-research-papers`, …) are available when a sub-question calls for one.
- **Exa** → `/exa:search` — the Exa Research Orchestrator (semantic search + parallel
  subagents, optimized for Exa). For async list-building / enrichment sub-questions,
  use `/exa:exa-agent` instead.

Use **both** providers for coverage — their search models surface different sources.

**Transport is MCP, not CLI.** Downstream, each provider skill reaches its engine over
MCP — Exa through the MCP server bundled in the `exa` plugin, Firecrawl through the
globally-configured Firecrawl MCP (the `firecrawl_*` tools; its API key is carried in
that server, not in this repo). The vendored Firecrawl skills use transport-agnostic
wording ("CLI or equivalent tool surface"); in this setup that surface is the Firecrawl
MCP. If the `firecrawl_*` MCP tools are not available, report that the Firecrawl MCP is
not configured — do not fall back to a CLI or a raw API key.

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

For EACH sub-question, dispatch the provider skills rather than calling MCP tools
directly. Hand each skill the sub-question plus any angle/recency constraints, and
let it run its own optimized search + scrape:

**Via Firecrawl:**
```
/firecrawl-workflows:firecrawl-deep-research  — scope it to a short/quick pass per sub-question
```

**Via Exa:**
```
/exa:search  — same sub-question; state recency/entity constraints in the prompt
```

Keep each per-sub-question dispatch scoped to a quick pass so the provider skills
stay lightweight; reserve a full provider run for a sub-question that is itself deep.

**Search strategy:**
- Use 2-3 different keyword variations per sub-question
- Mix general and news-focused queries
- Aim for 15-30 unique sources total
- Prioritize: academic, official, reputable news > blogs > forums
- Dedupe sources that both providers return

### Step 4: Deep-Read Key Sources

The provider skills scrape and read full sources as part of their own flow, so most
deep reads already happen in Step 3. When you need a specific URL the skills did not
already read in full, route it back through the same provider skill (`/exa:search`
and `/firecrawl-workflows:firecrawl-deep-research` both fetch and read full page
content) rather than calling a scrape tool directly.

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
"Deep dive into Rust vs Go for backend services in 2026"
"Research the best strategies for bootstrapping a SaaS business"
"What's happening with the US housing market right now?"
"Investigate the competitive landscape for AI code editors"
```
