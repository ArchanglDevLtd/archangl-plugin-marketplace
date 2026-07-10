# Competitor Snapshot

**When to use**: Analyze, profile, or understand a specific competitor.

## Data Gathering

```
# 1: Discover website + news
apify actors call: apify/google-search-scraper  # "[competitor name]" branded query

# 2: Scrape key pages (parallel)
apify actors call: apify/website-content-crawler  # homepage, /pricing, /about

# 3: Structured enrichment (parallel, if URLs available)
apify actors call: dev_fusion/Linkedin-Company-Scraper
apify actors call: pratikdani/crunchbase-companies-scraper

# 4: Temporal context — what changed?
apify actors call: andok/wayback-machine-scraper  # homepage + pricing ~1 year ago

# 5: Recent news — last 7 days
apify actors call: data_xplorer/google-news-scraper-fast
```

## Analysis

Synthesize into: positioning, target audience, key claims, strengths, vulnerabilities. Compare to user's product if context available. Highlight **changes over time** (Wayback) and **recent momentum** (news).
