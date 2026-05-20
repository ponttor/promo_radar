# Consigliere — Competitor Promo Radar

An internal tool for monitoring competitor promotional activity. Tracks websites and Instagram accounts, automatically extracts promotions, builds a change history, and generates daily reports with an AI summary.

---

## Concept

Consigliere solves the observation problem: know what competitors are doing with promotions before you have to find out manually.

**Data sources:**
- Competitor websites — periodic page snapshots with content diff
- Competitor Instagram accounts — post scraping via stored session

**What happens with the data:**
1. Sources are polled on a schedule (or on demand)
2. Changes are recorded as events: new promotion, update, ending, reappearance
3. Events feed into reports — generated daily automatically or on demand, with an AI-written summary

---

## Stack

- **Ruby 3.3.5 / Rails 7.2** — backend
- **Inertia.js + React** — UI with no separate API layer
- **Mantine** — UI components
- **PostgreSQL** — data storage (JSONB for extraction metadata, report scopes, meta tags)
- **Sidekiq + Redis** — background jobs and scheduling
- **Vite** — JS bundler
- **Playwright** — headless browser for Instagram scraping
- **ActiveHarness** — LLM agent framework (OpenRouter)
- **Nokogiri / Faraday / Redcarpet** — HTML parsing, HTTP, Markdown rendering

---

## How it works

### Website monitoring

`FetchSource` makes an HTTP GET (Faraday, 30 s timeout) and stores a `SourceSnapshot` with the full HTML, cleaned visible text, and a SHA-256 content hash. On success, `ExtractPromotions` runs immediately:

1. **Rule-based pass** — regex patterns for % discounts, cashback, promo codes, free spins, euro bonus amounts, named bonus types
2. **LLM fallback** — if rule-based finds nothing and text ≥ 100 chars, `PromotionExtractorAgent` is called

Each candidate is then normalized (lowercase title, uppercase code, SHA-256 fingerprint) and matched against existing promotions — creating or updating a `Promotion` + `PromotionVersion` + `PromotionEvent`.

### Instagram monitoring

`FetchInstagramPosts` launches a headless Chromium browser via Playwright, loading a stored session from `InstagramCredential`. It scrolls the account page up to 15 times, visits each post, and extracts caption, likes, comments, and publish date from Open Graph meta tags. Posts are deduplicated by `instagram_id`. No AI is involved.

### PromotionExtractorAgent

`ActiveHarness::Agent` subclass. Sends the visible text (first 8 000 chars) to `anthropic/claude-haiku-4-5` via OpenRouter with `temperature: 0.1`. The model returns a JSON array of structured promotions. Three free-tier fallbacks (Llama, Qwen, Gemma) are tried in order if the primary fails. If all models fail, extraction silently returns `[]`.

### Report generation

`GenerateReport` pulls two data sources for the given date range:
- `PromotionEvent` records — from the website extraction pipeline
- `InstagramPost` records — filtered by `posted_at`

Both are fed as text lines to `ReportSummaryAgent` (`claude-haiku-4-5`, `temperature: 0.4`), which writes an executive summary in Slovak in the style of a Godfather informant. The structural report (per-competitor promotion events + Instagram posts) is rendered as HTML via Redcarpet. The AI summary is stored separately in `scope_json["ai_summary"]` and displayed in a distinct UI block.

### Schedule

| Time | Job | What it does |
|------|-----|-------------|
| 06:00 daily | `FetchAllSourcesJob` | Fetch all active website sources, extract promotions |
| 07:00 daily | `GenerateDailyReportJob` | Mark stale promotions as expired, generate daily report with AI summary |

---

## Running locally

```bash
bin/setup                        # first time: bundle + db:prepare
foreman start -f Procfile.dev    # Rails :3000 + Vite :3036
```
