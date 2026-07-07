---
description: Multi-source deep research using the Firecrawl and Exa provider skills. Plans a topic into sub-questions, searches the web, and delivers a cited report with source attribution. Use for thorough research on any topic with evidence and citations.
argument-hint: [topic to research]
disable-model-invocation: true
---

Run the archangl multi-source **deep research** workflow.

**Research topic:** $ARGUMENTS

Execute the full workflow defined in this plugin's `archangl-deep-research` skill
(`skills/archangl-deep-research/SKILL.md`): plan the topic into 3–5 sub-questions,
then for each one orchestrate the provider **skills** — Firecrawl via
`/firecrawl-workflows:firecrawl-deep-research` and Exa via `/exa:search` (with
`/exa:exa-agent` for async list-building / enrichment) — rather than calling their
`firecrawl_*` / Exa MCP tools directly. Use both providers for coverage, deep-read
the key sources, then synthesize a cited report with full source attribution.

Invoke the `archangl-deep-research` skill now and follow its steps exactly. If no
topic is provided above, ask the user what to research before starting.
