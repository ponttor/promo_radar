# Consigliere — Competitor Promo Radar

A competitor promotion monitoring system.

---

## Concept

### v1 — Collection & Structure

The first version solves the observation problem: gather everything competitors are doing and present it in a readable form.

**Data sources:**
- Competitor Instagram accounts — post scraping via session
- Websites — periodic page snapshots (HTTP + content hash diff)

**What happens with the data:**
1. Sources are polled on a schedule (Sidekiq Cron)
2. Changes are recorded as events: new promotion, update, ending, reappearance
3. Events feed into reports — generated daily (automatically) or on demand

**Output:** a structured activity log for each competitor, plus periodic digests.

---

### v2 — AI Analysis & Dialogue

The second version adds a layer of understanding: not just storing and displaying, but interpreting and responding.

**What changes:**
- AI analyzes accumulated data: detects patterns, compares strategies, gauges promotional aggression
- Reports are generated not from a template but on request — in whatever format and with whatever focus is needed right now
- The interface becomes conversational: ask "what was MonacoBet doing over the last two weeks?" or "who was cutting prices before the weekend?"

**The principle:** the structured data collected in v1 becomes knowledge you can talk to.

---

## Stack

- **Ruby 3.3.5 / Rails 7.2** — backend
- **Inertia.js + React** — UI with no separate API layer
- **Mantine** — UI components
- **PostgreSQL** — data storage
- **Sidekiq + Redis** — background jobs and scheduling
- **Vite** — JS bundler

## Running locally

```bash
bin/setup                        # first time: bundle + db:prepare
foreman start -f Procfile.dev    # Rails :3000 + Vite :3036
```
