# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Ruby 3.3.5 / Rails 7.2.3**
- **PostgreSQL** — databases: `promo_radar_development`, `promo_radar_test`
- **Inertia.js** (`inertia_rails` + `@inertiajs/react`) — primary UI pattern, bridges Rails controllers with React
- **React** — frontend framework (via Inertia, not a separate SPA)
- **Mantine** (`@mantine/core`, `@mantine/hooks`) — UI component library
- **Vite** (`vite_rails`) — JS bundler, dev server on port 3036
- **RuboCop** (omakase style) — Ruby linter
- **Minitest** + Capybara/Selenium — test suite

## Commands

**Development (requires both processes):**
```bash
foreman start -f Procfile.dev   # starts Rails (port 3000) + Vite (port 3036) together
# or separately:
bin/rails s
bin/vite dev
```

**Database:**
```bash
bin/setup              # first-time setup: bundle + db:prepare
bin/rails db:migrate
bin/rails db:prepare   # create + migrate + seed if needed
```

**Tests:**
```bash
bin/rails test                              # all unit/integration tests
bin/rails test:system                       # system tests (Capybara + Chrome)
bin/rails test test/models/user_test.rb     # single file
bin/rails test test/models/user_test.rb:42  # single test by line
```

**Lint & Security:**
```bash
bin/rubocop            # lint Ruby (omakase style)
bin/rubocop -a         # auto-fix safe offenses
bin/brakeman           # static security scan
```

## Architecture

### Inertia.js Pattern

This app uses Inertia.js as the glue between Rails and React — there is **no separate API layer**. Controllers render React components directly:

```ruby
# controller
def index
  render inertia: 'Users/Index', props: { users: User.all }
end
```

React components receive `props` as regular React props. Pages live in `app/javascript/` (conventionally under a `pages/` subfolder). The Rails layout (`app/views/layouts/application.html.erb`) bootstraps the Inertia root div via Vite tags — ERB views are only used for the layout shell.

### JavaScript / Vite

- Vite entrypoint: `app/javascript/entrypoints/application.js`
- Stimulus controllers (legacy): `app/javascript/controllers/` — loaded via importmap
- React/Inertia pages: `app/javascript/` (to be organized under `pages/` or `components/`)
- Vite config: `vite.config.ts` + `config/vite.json`

### Testing

CI runs: Brakeman → importmap audit → RuboCop → Minitest + system tests (against a real Postgres).
