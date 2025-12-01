# Beam Deflection Calculator

Rails 8 app that lets users calculate beam deflections through a web UI and a REST JSON API. It uses PostgreSQL, Redis (JWT blacklist), and MinIO for beam images.

## Quick start (Docker Compose)
- Copy env: `cp env.example .env` and set `SECRET_KEY_BASE` (generate with `docker-compose run --rm web bin/rails secret`).
- Run stack: `docker-compose up --build`.
- Prep DB: `docker-compose exec web bin/rails db:prepare`.
- Optional demo data and tokens: `docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb` (creates `user@demo.com` and `moderator@demo.com`, both `password123`).
- Open web UI: http://localhost:3000, API docs: http://localhost:3000/api-docs, API base: http://localhost:3000/api.

## Auth quick reference
- Sign up: `POST /api/auth/sign_up`
- Sign in: `POST /api/auth/sign_in` (returns JWT for `Authorization: Bearer <token>`)
- Sign out: `DELETE /api/auth/sign_out` (token is blacklisted in Redis)
- Tokens expire after 24h; blacklisted tokens are rejected automatically.

## Running locally without Docker
- Install Ruby (see `.ruby-version`) and Bundler, then `bundle install`.
- Set env vars from `env.example` (including `SECRET_KEY_BASE`).
- `bin/rails db:prepare`
- `bin/rails s`

## Tests and quality
- RSpec: `bundle exec rspec`
- RuboCop: `bundle exec rubocop`
- Security scan: `bundle exec brakeman`

## Helpful docs and scripts
- `utilities/docs/CLAUDE.md` - architecture and dev commands
- `utilities/docs/SWAGGER_ENDPOINTS.md`, `utilities/docs/SWAGGER_LOGIN_GUIDE.md`, Swagger UI for endpoint details
- `docs/guides/DEMO_GUIDE.md`, `docs/guides/QUICK_DEMO_COMMANDS.md` - step-by-step demo flows
- `docs/guides/INSOMNIA_SETUP_GUIDE.md` and `Insomnia_Collection*.json` - prebuilt API client collections
- `utilities/scripts/prepare_demo.rb` - seeds demo users, beams, requests, and prints ready-to-use JWTs
- More utility docs (API workflow, verification checklists, quick token setup) live in `utilities/docs/`
- Additional helper/test scripts (checks, demo data, Redis helpers) live in `utilities/scripts/`

## Notes
- Redis is required for JWT blacklist; MinIO is required for beam images (see `config/initializers/minio.rb`).
- Domain terms use "beams" and "beam_deflections" (legacy "services/requests" wording may still appear in comments).
