#!/usr/bin/env python3
"""Fetch data from German Handelsregister via Apify actor.

Requires: APIFY_TOKEN in the environment (Apify REST API; no other transport).
Actor: radeance/handelsregister-api ($0.01/search, 99.5% success, rating 5.0)

Usage:
    python fetch_all.py                # fetch all companies
    python fetch_all.py keyword Siemens # search by keyword

Sources:
  handelsregister — Německý obchodní rejstřík (via Apify). Strukturovaná data: název,
                    právní forma, sídlo, základní kapitál, předmět podnikání, management
                    (jména + data narození), registrační soud, HRB číslo.
                    Žádné přímé DE entity, ale konkurenti Škoda Transportation ano
                    (Siemens Mobility, Stadler, Alstom). Relevantní pro DE telco (T-Mobile).
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

ACTOR = "radeance/handelsregister-api"
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


def apify_call_actor(input_data: dict, timeout: int = 120) -> dict:
    """Run the Apify Actor via the REST API and return run info + items
    (same shape the callers already consume: runId, datasetId, itemCount, items)."""
    actor = ACTOR.replace("/", "~")
    run = _api(f"/acts/{actor}/runs?waitForFinish=60",
               data=json.dumps(input_data).encode(), timeout=timeout + 30)["data"]
    deadline = time.time() + timeout
    while run.get("status") in ("READY", "RUNNING") and time.time() < deadline:
        time.sleep(5)
        run = _api(f"/actor-runs/{run['id']}")["data"]
    if run.get("status") != "SUCCEEDED":
        return {"error": f"run {run.get('id')} ended with status {run.get('status')}"}
    dataset_id = run.get("defaultDatasetId")
    items = apify_get_output(dataset_id) if dataset_id else []
    return {"runId": run.get("id"), "datasetId": dataset_id,
            "itemCount": len(items), "items": items}


def apify_get_output(dataset_id: str, limit: int = 100) -> list:
    """Get actor output from dataset."""
    try:
        return _api(f"/datasets/{dataset_id}/items?limit={limit}&clean=true")
    except Exception:
        return []


def search_company(keyword: str) -> dict:
    """Search Handelsregister by company keyword."""
    return apify_call_actor({"keyword": keyword})


def fetch_all():
    print(f"=== DE Handelsregister (via {ACTOR}) ===")
    results = {}

    all_companies = {}
    for sector, companies in COMPANIES.get("competitors", {}).items():
        for reg_id, info in companies.items():
            all_companies[reg_id] = {**info, "sector": sector}

    for reg_id, info in all_companies.items():
        keyword = info.get("keyword", info.get("name", ""))
        print(f"  Searching: {keyword}...")
        try:
            result = search_company(keyword)
            run_id = result.get("runId")
            dataset_id = result.get("datasetId")
            item_count = result.get("itemCount", 0)
            items = result.get("items", [])

            results[reg_id] = {
                "keyword": keyword,
                "sector": info.get("sector"),
                "run_id": run_id,
                "item_count": item_count,
                "data": items[:5],
            }
            print(f"    OK: {item_count} results, runId={run_id}")
            time.sleep(1.0)
        except Exception as e:
            results[reg_id] = {"keyword": keyword, "error": str(e)}
            print(f"    ERR: {e}")

    out = OUTPUT_DIR / "handelsregister.json"
    with open(out, "w") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"  Saved {len(results)} searches to {out}")
    return results


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "keyword":
        keyword = " ".join(sys.argv[2:])
        print(f"Searching: {keyword}")
        result = search_company(keyword)
        print(json.dumps(result, indent=2, ensure_ascii=False)[:2000])
    else:
        fetch_all()
