# Agent instructions

## Git commits

Always commit completed work without waiting to be asked. After finishing a logical
change (or a coherent batch of related changes), create a commit using the repo’s
existing commit style. Do not leave finished work uncommitted.

Still follow normal git safety: never update git config, never force-push to
main/master, never use destructive git commands unless explicitly requested, and
never commit secrets (`.env`, credentials, etc.).

## Testing

This app uses a three-layer Minitest suite. Prefer the cheapest layer that can
observe the behavior.

### Layers

1. **Unit** (`test/models`, `test/sidekiq`) — `RequestManager`, `JobManager`, and
   `Job` only. No controller or view unit tests.
2. **HTTP end-to-end** (`test/integration`) — rack-test / integration tests for
   routes and server-rendered HTML/JSON when no JavaScript is required. Controllers
   and views are covered here, not in isolation.
3. **Browser end-to-end** (`test/system`) — Rails system tests with **Cuprite**
   (Chromium via CDP). Use only for Alpine.js behavior (`requestInterceptor`,
   `queuePoller`).

### Commands

```bash
# Unit + HTTP E2E (needs Redis for some jobs/Sidekiq paths)
bundle exec rails test

# Browser E2E (needs Redis + Chromium/Chrome)
bundle exec rails test:system

# Headed browser locally
HEADLESS=0 bundle exec rails test test/system
```

Test env defaults (set in `test/test_helper.rb` when unset): `SECRET_KEY_BASE`,
`REDIS_URL=redis://127.0.0.1:6379/15`. If `app/assets/builds/tailwind.css` is
missing (fresh clone / CI), the helper runs `rails tailwindcss:build`.

### Conventions

- Do not add controller or view unit tests; extend integration or system tests.
- Keep system tests few and stable; use short latencies (e.g. 100 ms) and low RPS.
- Sidekiq defaults to `Sidekiq::Testing.fake!` in unit/integration tests. System
  tests disable fake mode and use Redis DB 15.
- CI: `.github/workflows/test.yml` runs `rails test` then `rails test:system`.
