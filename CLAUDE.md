# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Beam Deflection Calculator** Rails 8 application with both a traditional web interface and a RESTful JSON API. The application allows users to:

- Browse beams (structural elements with material properties)
- Create beam deflection calculations by selecting beams and specifying load parameters
- Submit calculations for moderator review
- View completed calculation results

**Domain Model**: The codebase recently underwent a refactoring from generic "services/requests" terminology to domain-specific "beams/beam_deflections" naming. Watch for legacy comments or names.

## Development Commands

### Docker Setup (Primary Method)

```bash
# Start all services (Rails app, PostgreSQL, MinIO)
docker-compose up

# Run migrations
docker-compose exec web bin/rails db:migrate

# Access Rails console
docker-compose exec web bin/rails console

# Stop services
docker-compose down
```

### Database

```bash
# Create and migrate database
bin/rails db:create db:migrate

# Reset database
bin/rails db:drop db:create db:migrate

# Run seeds if they exist
bin/rails db:seed
```

### Testing

```bash
# Run all specs (RSpec + Swagger integration tests)
bundle exec rspec

# Run specific integration spec
bundle exec rspec spec/integration/beams_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### API Documentation

- Swagger UI: <http://localhost:3000/api-docs>
- OpenAPI spec: `swagger/v1/swagger.yaml`
- Tests generate/update the Swagger documentation

### Code Quality

```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix offenses
bundle exec rubocop -A

# Security scanning
bundle exec brakeman
```

## Architecture

### Core Domain Models

### Beam

**File**: `app/models/beam.rb`

- Represents structural beam elements with material properties
- Key fields: `name`, `material`, `elasticity_gpa`, `inertia_cm4`, `allowed_deflection_ratio`
- Materials: `wooden`, `steel`, `reinforced_concrete`
- Uses `BeamScopes` concern for query scopes
- Soft deletion via `active` flag

### BeamDeflection

**File**: `app/models/beam_deflection.rb`

- User-submitted calculation requests with state machine workflow
- Statuses: `draft` → `formed` → `completed` / `rejected` (or `deleted`)
- Key fields: `length_m`, `udl_kn_m`, `result_deflection_mm`
- Uses `BeamDeflectionScopes` concern
- Contains deflection calculation logic in `compute_and_store_result_deflection!`

### BeamDeflectionBeam

**File**: `app/models/beam_deflection_beam.rb`

- Join model with additional attributes (many-to-many)
- Fields: `quantity`, `is_primary`, `position`, `deflection_mm`
- Stores calculated deflection per beam

### User

**File**: `app/models/user.rb`

- JWT-based authentication with `has_secure_password`
- `moderator` boolean flag for permissions
- Relationships: `beam_deflections` (created), `moderated_beam_deflections` (reviewed)

### State Machine

#### BeamDeflectionStateMachine

**File**: `app/services/beam_deflection_state_machine.rb`

- Enforces valid status transitions with role-based authorization
- `draft` → `formed` (creator only)
- `draft` → `deleted` (creator only)
- `formed` → `completed` (moderators only)
- `formed` → `rejected` (moderators only)

### Authentication & Authorization

#### JWT Authentication

- `JwtToken` class (`app/lib/jwt_token.rb`) handles encoding/decoding
- 24-hour token expiration
- Secret: Uses `SECRET_KEY_BASE` env var or Rails credentials
- **JWT Blacklist**: Tokens are invalidated on sign out using Redis
  - `JwtBlacklist` service (`app/services/jwt_blacklist.rb`) manages blacklisted tokens
  - Blacklisted tokens stored in Redis with TTL (auto-expire when token expires)
  - `JwtToken.decode` automatically checks blacklist
  - Sign out adds current token to blacklist via `JwtToken.blacklist!(token)`

#### Redis Integration

- Used for JWT blacklist storage
- Configured in `config/initializers/redis.rb`
- Connection: `Rails.application.config.redis`
- Default URL: `redis://redis:6379/0` (Docker network)

#### API Base Controller

**File**: `app/controllers/api/base_controller.rb`

- `authenticate_request` before_action extracts Bearer token
- Sets `Current.user` for request-scoped user access
- `require_auth!` / `require_moderator!` helpers
- Automatically rejects blacklisted tokens (401 Unauthorized)

#### Authorization

- Uses Pundit gem (`gem "pundit"`)
- Role-based: regular users vs moderators
- Instance methods on models: `can_form_by?`, `can_complete_by?`, `can_reject_by?`

### API Structure

All API routes under `/api` namespace:

- `/api/auth/sign_in`, `/api/auth/sign_up`, `/api/auth/sign_out`
- `/api/me` - Current user profile
- `/api/beams` - CRUD for beams (moderator-only for create/update/delete)
- `/api/beam_deflections` - Calculation management
  - `PUT /api/beam_deflections/:id/form` - Submit draft
  - `PUT /api/beam_deflections/:id/complete` - Moderator approval
  - `PUT /api/beam_deflections/:id/reject` - Moderator rejection
  - Nested routes for item management via `beam_deflection_items_controller`
- `/api/beam_deflections/cart_badge` - Draft items count

### File Storage (MinIO)

**MinIO Integration** (`app/helpers/minio_helper.rb`, `config/initializers/minio.rb`)

- S3-compatible object storage for beam images
- Internal endpoint: `http://minio:9000` (Docker network)
- External endpoint: `http://localhost:9000` (browser access)
- Bucket: `beam-deflection`
- Helper methods: `minio_image_url`, `minio_upload`, `minio_delete`
- Fallback: Generates inline SVG placeholder for missing images

### Web Interface

Traditional Rails views for public browsing:

- `app/views/beams/` - Beam catalog
- `app/views/carts/` - Draft calculation ("cart")
- `app/views/orders/` - Completed calculations
- Uses session-based auth with auto-created demo user for web UI

### Database Architecture

- **PostgreSQL** (development, test, production)
- Docker service: `db` on port 5432
- Test database: Isolated with `beam_deflection_test` name
- Connection: Configured via `config/database.yml` with env var overrides

- **Redis** (JWT blacklist, caching)
- Docker service: `redis` on port 6379
- Persistence: AOF (append-only file) enabled
- Connection: `redis://redis:6379/0`

## Important Patterns

### Concerns Usage

- `BeamScopes` and `BeamDeflectionScopes` extract query scopes and constants
- Status predicates (`draft?`, `formed?`) defined in scopes concern

### Legacy Compatibility

- Beam model has compatibility aliases: `e_gpa`, `norm`, `image_url`
- BeamDeflection has duplicate validation/scope definitions (technical debt)

### Current.user Pattern

- Thread-safe user context via `Current.user = user`
- Set in `Api::BaseController#authenticate_request` and `ApplicationController#set_current_user`

## Testing Strategy

- **Integration tests** (`spec/integration/`) use Swagger spec format
- Tests define and validate OpenAPI documentation
- Use `swagger_helper` for shared configuration
- Create test users/moderators per test
- JWT tokens generated via `JwtToken.encode(user_id: ..., exp: ...)`

## Environment Variables

Key variables (see `.env` and `docker-compose.yml`):

- `DATABASE_HOST`, `DATABASE_NAME`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`
- `REDIS_URL` - Redis connection URL (default: `redis://redis:6379/0`)
- `MINIO_INTERNAL_ENDPOINT`, `MINIO_EXTERNAL_ENDPOINT`
- `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_BUCKET`
- `SECRET_KEY_BASE` - JWT signing key
- `RAILS_ENV` - Environment (development/test/production)

## Common Pitfalls

1. **Naming inconsistency**: Some files/comments may still reference old "Service/Request" names instead of "Beam/BeamDeflection"
2. **Duplicate code**: `BeamDeflection` model has redundant validations and scope definitions at bottom
3. **Test database**: Integration tests require `config.hosts << "www.example.com"` in test environment
4. **MinIO URLs**: Must distinguish internal (Docker network) vs external (browser) endpoints
5. **State transitions**: Always use `BeamDeflectionStateMachine` or model methods (`mark_as_formed!`, `complete!`, `reject!`) rather than direct status updates
6. **JWT Security**: Blacklisted tokens are only rejected if Redis is running. If Redis fails, tokens remain valid until expiration (fail-open for availability)

## Rails Version

- Rails 8.0.3
- Ruby 3.3.9
- No Active Job, Active Storage, Action Mailer configured (disabled in `config/application.rb`)
