#!/usr/bin/env python3
"""Fetch data from UK Companies House via Apify actor.

Requires: APIFY_TOKEN in the environment (Apify REST API; no other transport).
Actor: dhrumil/company-house-scraper (pay-per-event, 95.7% success, rating 5.0)

Usage:
    python fetch_all.py              # fetch all companies
    python fetch_all.py search NAME  # search by name

Sources:
  companies_house — UK Companies House (via Apify). Company number, status, adresa,
                    SIC kódy, datum inkorporace, officers (directors + secretary),
                    accounts timeline, confirmation statement.
                    Portfolio entita: ClearBank Group Holdings Ltd (#14254435).
                    Konkurenti: Modulr, Starling Bank, Monzo Bank.
"""

import json
import os
import sys
import time
import urllib.request
from pathlib import Path

BASE_DIR = Path(__file__).parent
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

with open(BASE_DIR / "lookup_targets.json") as f:
    COMPANIES = json.load(f)

ACTOR = "dhrumil/company-house-scraper"

CH_SEARCH_BASE = "https://find-and-update.company-information.service.gov.uk/advanced-search/get-results"


def build_search_url(company_name: str) -> str:
    """Build Companies House advanced search URL."""
    from urllib.parse import urlencode
    params = {
        "companyNameIncludes": company_name,
        "companyNameExcludes": "",
    }
    return f"{CH_SEARCH_BASE}?{urlencode(params)}"


API = "https://api.apify.com/v2"


def _api(path: str, data: bytes | None = None, timeout: int = 60):
    """Authenticated Apify REST request (APIFY_TOKEN from the environment)."""
    token = os.environ["APIFY_TOKEN"]
    req = urllib.request.Request(
        f"{API}{path}",
        data=data,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.load(r)


def apify_call_actor(input_data: dict, timeout: int = 180, actor: str | None = None) -> dict:
    """Run an Apify Actor via the REST API; returns runId/datasetId/itemCount/items."""
    slug = (actor or ACTOR).replace("/", "~")
    run = _api(f"/acts/{slug}/runs?waitForFinish=60",
               data=json.dumps(input_data).encode(), timeout=timeout + 30)["data"]
    deadline = time.time() + timeout
    while run.get("status") in ("READY", "RUNNING") and time.time() < deadline:
        time.sleep(5)
        run = _api(f"/actor-runs/{run['id']}")["data"]
    if run.get("status") != "SUCCEEDED":
        return {"error": f"run {run.get('id')} ended with status {run.get('status')}",
                "runId": run.get("id"), "datasetId": run.get("defaultDatasetId")}
    dataset_id = run.get("defaultDatasetId")
    items = []
    if dataset_id:
        try:
            items = _api(f"/datasets/{dataset_id}/items?limit=100&clean=true")
        except Exception:
            items = []
    return {"runId": run.get("id"), "datasetId": dataset_id,
            "itemCount": len(items), "items": items}


def search_company(name: str, max_companies: int = 10) -> dict:
    """Search Companies House by company name."""
    search_url = build_search_url(name)
    return apify_call_actor({
        "listUrls": [{"url": search_url}],
        "maxCompanies": max_companies,
    })


def fetch_all():
    print(f"=== UK Companies House (via {ACTOR}) ===")
    results = {}

    # Collect all companies to search
    all_searches = {}
    for key, info in COMPANIES.get("portfolio", {}).items():
        if isinstance(info, dict) and "keyword" in info:
            all_searches[key] = info
    for sector, companies in COMPANIES.get("competitors", {}).items():
        for key, info in companies.items():
            all_searches[key] = {**info, "sector": sector}

    for key, info in all_searches.items():
        keyword = info.get("keyword", info.get("name", ""))
        print(f"  Searching: {keyword}...")
        try:
            result = search_company(keyword, max_companies=5)
            run_id = result.get("runId")
            item_count = result.get("itemCount", 0)
            items = result.get("items", [])

            results[key] = {
                "keyword": keyword,
                "sector": info.get("sector", "unclassified"),
                "run_id": run_id,
                "item_count": item_count,
                "data": items[:3],
            }
            print(f"    OK: {item_count} results")
            time.sleep(1.0)
        except Exception as e:
            results[key] = {"keyword": keyword, "error": str(e)}
            print(f"    ERR: {e}")

    out = OUTPUT_DIR / "companies_house.json"
    with open(out, "w") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"  Saved {len(results)} searches to {out}")
    return results


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "search":
        name = " ".join(sys.argv[2:])
        print(f"Searching: {name}")
        result = search_company(name)
        print(json.dumps(result, indent=2, ensure_ascii=False)[:2000])
    else:
        fetch_all()
