# Content & SEO Battle

**When to use**: Understand competitors' content strategy or search positioning.

## Data Gathering

```
# 1: SERP rankings for category keywords (parallel, 4-6 buyer keywords, NOT brand terms)
apify actors call: apify/google-search-scraper
  input: { "queries": "[category] tools comparison [current-year]\nbest [category] platform\n[category] alternatives\n[use case] software", "maxPagesPerQuery": 1 }

# 2: Indexed content volume
apify actors call: apify/google-search-scraper
  input: { "queries": "site:[competitor.com]\nsite:[competitor-2.com]" }

# 3: Traffic data (may be empty for small sites)
apify actors call: pro100chok/similarweb-scraper  # minimum 10 domains — batch all competitors in one call

# 4: Blog/content strategy
apify actors call: apify/website-content-crawler  # [competitor-url]/blog, crawl 10 pages
```

The most valuable SEO finding is often **absence** — not ranking for category keywords is a critical gap.

## Analysis

Map competitors to keywords. Estimate content volume and frequency. Identify topic clusters. Find content gaps — topics nobody covers well that user could own.
