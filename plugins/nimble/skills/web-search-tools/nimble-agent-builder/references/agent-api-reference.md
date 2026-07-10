# Agent API Reference

Reference for Nimble agent CLI commands and input parameter mapping. For the generate → poll → publish lifecycle, see `generate-update-and-publish.md`.

**CLI commands** (run via Bash — primary for all operations):
- `nimble agent list`, `nimble agent get`, `nimble agent run`, `nimble agent run-async`
- `nimble agent generate`, `nimble agent get-generation`, `nimble agent publish`
- `nimble search`, `nimble extract`, `nimble map`


---

## CLI: nimble agent list

Search and paginate through available agents.

```bash
nimble agent list --limit 100
nimble agent list --limit 100 --search "amazon"
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--limit <n>` | 50 | Max results. Maximum 100. Always use `--limit 100` for discovery. |
| `--search <term>` | — | Filter by keyword. Use short terms, not full sentences. |
| `--offset <n>` | 0 | Offset for pagination. |

### Output

Returns a list of agents with `name` and `description`. Filter the results locally — do not call multiple times with different queries. One call with `--limit 100`, then filter in memory.

---

## CLI: nimble agent get

Retrieve full schema for a single agent — input parameters and output fields.

```bash
nimble agent get --template-name <agent_name>
```

### Output fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Agent identifier. |
| `description` | string | What the agent extracts. |
| `input_properties` | array | List of input parameter objects (see "Input Parameter Mapping" below). |
| `skills` | object | Output field definitions — keys are field names, values describe their type. |
| `entity_type` | string | `"Search Engine Results Page (SERP)"` or `"Product Detail Page (PDP)"`. Determines response shape — see "Response shape inference" below. |
| `feature_flags` | object | Capabilities: `is_pagination_supported`, `is_localization_supported`. |

### Response shape inference

Use `entity_type` and `skills` from `nimble agent get` to predict the `data.parsing` shape:

| `entity_type` | `skills` structure | `data.parsing` shape |
|---------------|-------------------|----------------------|
| PDP | Flat fields | `dict` — single record |
| SERP (ecommerce) | Flat fields | `list` — array of records |
| SERP (non-ecommerce) | Nested fields (contains `entities`, `total_entities_count`) | `dict` — with `entities.{EntityType}` arrays |

**Always inspect `skills` before generating code** to determine which shape applies. See `sdk-patterns.md` > "Response structure verification".

---

## CLI: nimble agent run

Execute an agent and get structured results.

```bash
nimble --transform "data.parsing" agent run --agent <name> --params '{"keyword": "..."}'
```

**Always use `--transform "data.parsing"`.** The raw response wraps structured data as `{html, parsing, headers}`. The `parsing` field is what you want — the transform extracts it in one shot. Never run without it and then parse manually.

### Options

| Flag | Required | Description |
|------|----------|-------------|
| `--agent <name>` | Yes | Agent name from `nimble agent list`. |
| `--params <json>` | Yes | JSON object matching the agent's `input_properties`. |

### Output

Returns `data.parsing` directly (after `--transform`):
- **SERP / list agents** → array of records
- **PDP / product agents** → dict (single record)

### Example

```bash
# SERP agent (returns array)
nimble --transform "data.parsing" agent run --agent amazon_serp --params '{"keyword": "trackpad"}'

# PDP agent (returns dict)
nimble --transform "data.parsing" agent run --agent amazon_pdp --params '{"asin": "B0CCZ1L489"}'
```

---

## CLI: nimble search

Real-time web search returning structured results.

```bash
nimble search --query "target domain keywords" --max-results 5
```

### When to use

- Exploring unfamiliar domains before committing to an agent approach.
- Finding real-world examples for agent generation (Discovery phase).
- General information-finding — preferred over `google_search` for this purpose.
- Fallback when a data source agent is down — see `error-recovery.md`.

### Output

Structured results with titles, URLs, and content snippets.

---

## Operation name glossary

The lifecycle docs (`generate-update-and-publish.md`, `error-recovery.md`, and
SKILL.md) refer to agent-platform operations by these bare names. Each one is
executed with the CLI command shown — there is no other transport:

| Operation name | CLI command |
|---|---|
| `nimble_agents_generate` | `nimble agent generate --agent-name <name> --prompt "<prompt>" --url "<url>"` |
| `nimble_agents_update_from_agent` | `nimble agent generate --from-agent <name> --prompt "<prompt>"` (call once to enter update mode) |
| `nimble_agents_update_session` | `nimble agent generate --from-agent <name> --prompt "<follow-up>"` (continue the same refinement session) |
| `nimble_agents_status` | `nimble agent get-generation --generation-id <id>` (read-only poll) |
| `nimble_agents_publish` | `nimble agent publish --agent-name <name> --version-id <id>` |

Session semantics on the CLI: `generate` returns a generation `id` — poll it
with `get-generation --generation-id`. Where the lifecycle docs say
"session_id", use that generation id. If a documented subcommand is missing
from your installed CLI version (`nimble agent --help` lists what exists),
stop and report the version mismatch rather than improvising an endpoint.

---

## Input Parameter Mapping

How to read an agent's `input_properties` (from `nimble agent get`) and build the `--params` JSON for `nimble agent run`.

### Mapping rules

The `--params` JSON maps 1:1 to `input_properties` names. Include all `required: true` properties; omit optional ones unless inferable from context.

**Rule:** Only ask the user for required parameters that cannot be inferred. Fill optional parameters when inferable; otherwise omit.

### Presenting schema to the user

When presenting agent schema before running, show a markdown table:

| Parameter | Required | Type | Description | Example |
|-----------|----------|------|-------------|---------|
| `query` | Yes | string | Search term | `"donald trump"` |
| `country` | No | string | Country code (default: US) | `"US"` |

Also note key output fields from `skills` so the user knows what data to expect.

### Common patterns

#### URL-based agents

```bash
# Required only
nimble --transform "data.parsing" agent run --agent <name> --params '{"url": "https://www.amazon.com/dp/B0DGHRT7PS"}'

# With optional param
nimble --transform "data.parsing" agent run --agent <name> --params '{"url": "https://www.amazon.com", "query": "wireless earbuds"}'
```

#### Identifier-based agents

| Site | Parameter | Example params |
|------|-----------|----------------|
| Amazon | `asin` | `{"asin": "B0CCZ1L489"}` |
| Walmart / Target | `product_id` | `{"product_id": "436473700"}` |
| LinkedIn | `identifier` | `{"identifier": "dustinlucien"}` |

#### Keyword/search agents

SERP agents use a keyword parameter — the name varies, check `input_properties`:

| Agent | Parameter | Example params |
|-------|-----------|----------------|
| `google_search` | `query` | `{"query": "fintech NYC"}` |
| `linkedin_search_peoples` | `keywords` | `{"keywords": "CTO fintech"}` |
| Amazon/Walmart SERP | `keyword` | `{"keyword": "wireless headphones"}` |

#### Non-URL agents

Some agents operate on a fixed domain and only need non-URL inputs:

```bash
nimble --transform "data.parsing" agent run --agent instagram_profile_by_account --params '{"username": "johndoe"}'
```

### Building params — step by step

1. Run `nimble agent get --template-name <name>` to read `input_properties`.
2. Identify all properties where `required: true`.
3. Map values from the user's request to matching parameter names. Use `examples` for guidance.
4. Ask via `AskUserQuestion` only for required values that cannot be inferred. Omit optional params unless inferable.
5. Run: `nimble --transform "data.parsing" agent run --agent <name> --params '{...}'`

### Also check output fields

Before running or generating code, inspect the `skills` dict from `nimble agent get` to understand what data the agent returns:
- **Interactive runs:** know which fields to show in the results table.
- **Script generation:** determine the correct response parsing shape — see "Response shape inference" above.
