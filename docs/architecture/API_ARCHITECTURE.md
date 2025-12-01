# API Architecture

## Обзор API структуры

Приложение предоставляет RESTful JSON API под префиксом `/api` с JWT-аутентификацией.

## Архитектурная диаграмма

```mermaid
graph TB
    subgraph "Client Layer"
        WEB[Web Browser]
        MOBILE[Mobile App]
        SWAGGER[Swagger UI]
    end

    subgraph "API Gateway"
        ROUTES[Routes /api/*]
    end

    subgraph "Authentication Middleware"
        AUTH[Api::BaseController]
        JWT[JwtToken Service]
        BLACKLIST[JwtBlacklist + Redis]
    end

    subgraph "Controllers Layer"
        AUTH_CTRL[AuthController]
        ME_CTRL[MeController]
        BEAMS_CTRL[BeamsController]
        BD_CTRL[BeamDeflectionsController]
        BDI_CTRL[BeamDeflectionItemsController]
    end

    subgraph "Business Logic"
        STATE_MACHINE[BeamDeflectionStateMachine]
        CALC[Calc::Deflection]
    end

    subgraph "Models Layer"
        USER[User]
        BEAM[Beam]
        BD[BeamDeflection]
        BDB[BeamDeflectionBeam]
    end

    subgraph "Data Layer"
        POSTGRES[(PostgreSQL)]
        REDIS[(Redis)]
        MINIO[(MinIO S3)]
    end

    WEB --> ROUTES
    MOBILE --> ROUTES
    SWAGGER --> ROUTES

    ROUTES --> AUTH
    AUTH --> JWT
    JWT --> BLACKLIST
    BLACKLIST --> REDIS

    AUTH --> AUTH_CTRL
    AUTH --> ME_CTRL
    AUTH --> BEAMS_CTRL
    AUTH --> BD_CTRL
    AUTH --> BDI_CTRL

    BD_CTRL --> STATE_MACHINE
    BD_CTRL --> CALC

    AUTH_CTRL --> USER
    BEAMS_CTRL --> BEAM
    BD_CTRL --> BD
    BDI_CTRL --> BDB

    BEAM --> MINIO
    USER --> POSTGRES
    BEAM --> POSTGRES
    BD --> POSTGRES
    BDB --> POSTGRES
```

## API Endpoints

### Authentication (`/api/auth`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/sign_up` | Регистрация нового пользователя | ❌ |
| POST | `/api/auth/sign_in` | Вход (получение JWT токена) | ❌ |
| POST | `/api/auth/sign_out` | Выход (добавление токена в blacklist) | ✅ |

#### Sign Up
**Request**:
```json
POST /api/auth/sign_up
{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "moderator": false
}
```

**Response** (201 Created):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "moderator": false
  }
}
```

#### Sign In
**Request**:
```json
POST /api/auth/sign_in
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "moderator": false
  }
}
```

#### Sign Out
**Request**:
```http
POST /api/auth/sign_out
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response** (200 OK):
```json
{
  "message": "Successfully signed out"
}
```

---

### Current User (`/api/me`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/me` | Получить профиль текущего пользователя | ✅ |
| PUT | `/api/me` | Обновить профиль текущего пользователя | ✅ |

#### Get Profile
**Request**:
```http
GET /api/me
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response** (200 OK):
```json
{
  "id": 1,
  "email": "user@example.com",
  "moderator": false,
  "created_at": "2025-01-01T10:00:00Z"
}
```

---

### Beams (`/api/beams`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/beams` | Список балок | ❌ | - |
| GET | `/api/beams/:id` | Информация о балке | ❌ | - |
| POST | `/api/beams` | Создать балку | ✅ | Moderator |
| PUT | `/api/beams/:id` | Обновить балку | ✅ | Moderator |
| DELETE | `/api/beams/:id` | Удалить балку (soft delete) | ✅ | Moderator |
| POST | `/api/beams/:id/add_to_draft` | Добавить балку в черновик | ✅ | User |
| POST | `/api/beams/:id/image` | Загрузить изображение | ✅ | Moderator |

#### List Beams
**Request**:
```http
GET /api/beams?material=steel&active=true
```

**Query Parameters**:
- `material` - фильтр по материалу (`wooden`, `steel`, `reinforced_concrete`)
- `active` - фильтр по активности (`true`/`false`)

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "name": "Двутавр 20",
    "material": "steel",
    "elasticity_gpa": 200.0,
    "inertia_cm4": 1840.0,
    "allowed_deflection_ratio": 250.0,
    "image_url": "http://localhost:9000/beam-deflection/beam_1.png",
    "active": true
  }
]
```

#### Create Beam
**Request**:
```json
POST /api/beams
Authorization: Bearer <moderator_token>

{
  "name": "Двутавр 30",
  "material": "steel",
  "elasticity_gpa": 200.0,
  "inertia_cm4": 7080.0,
  "allowed_deflection_ratio": 250.0
}
```

**Response** (201 Created):
```json
{
  "id": 2,
  "name": "Двутавр 30",
  "material": "steel",
  "elasticity_gpa": 200.0,
  "inertia_cm4": 7080.0,
  "allowed_deflection_ratio": 250.0,
  "image_url": null,
  "active": true
}
```

#### Add to Draft
**Request**:
```json
POST /api/beams/1/add_to_draft
Authorization: Bearer <user_token>

{
  "quantity": 2
}
```

**Response** (200 OK):
```json
{
  "message": "Beam added to draft",
  "beam_deflection_id": 5,
  "item": {
    "beam_id": 1,
    "quantity": 2,
    "is_primary": false
  }
}
```

---

### Beam Deflections (`/api/beam_deflections`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/beam_deflections` | Список расчетов | ✅ | User/Moderator |
| GET | `/api/beam_deflections/:id` | Детали расчета | ✅ | Creator/Moderator |
| PUT | `/api/beam_deflections/:id` | Обновить параметры | ✅ | Creator (draft only) |
| DELETE | `/api/beam_deflections/:id` | Удалить расчет | ✅ | Creator (draft only) |
| PUT | `/api/beam_deflections/:id/form` | Оформить расчет | ✅ | Creator (draft→formed) |
| PUT | `/api/beam_deflections/:id/complete` | Одобрить расчет | ✅ | Moderator (formed→completed) |
| PUT | `/api/beam_deflections/:id/reject` | Отклонить расчет | ✅ | Moderator (formed→rejected) |
| GET | `/api/beam_deflections/cart_badge` | Количество элементов в корзине | ✅ | User |

#### List Deflections
**Request**:
```http
GET /api/beam_deflections?status=formed
Authorization: Bearer <token>
```

**Query Parameters**:
- `status` - фильтр по статусу
- `creator_id` - фильтр по создателю (только для модераторов)

**Response** (200 OK):
```json
[
  {
    "id": 5,
    "creator_id": 1,
    "moderator_id": null,
    "status": "formed",
    "length_m": 6.0,
    "udl_kn_m": 10.5,
    "result_deflection_mm": 12.34,
    "within_norm": true,
    "formed_at": "2025-01-01T10:30:00Z",
    "items_count": 2,
    "beams": [
      {
        "beam_id": 1,
        "name": "Двутавр 20",
        "quantity": 2,
        "deflection_mm": 6.17
      }
    ]
  }
]
```

#### Get Deflection Details
**Request**:
```http
GET /api/beam_deflections/5
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "id": 5,
  "creator": {
    "id": 1,
    "email": "user@example.com"
  },
  "moderator": null,
  "status": "formed",
  "length_m": 6.0,
  "udl_kn_m": 10.5,
  "result_deflection_mm": 12.34,
  "within_norm": true,
  "formed_at": "2025-01-01T10:30:00Z",
  "completed_at": null,
  "beam_deflection_beams": [
    {
      "id": 10,
      "beam_id": 1,
      "beam_name": "Двутавр 20",
      "quantity": 2,
      "is_primary": true,
      "position": 1,
      "deflection_mm": 6.17
    }
  ]
}
```

#### Update Deflection
**Request**:
```json
PUT /api/beam_deflections/5
Authorization: Bearer <user_token>

{
  "length_m": 8.0,
  "udl_kn_m": 15.0
}
```

**Response** (200 OK):
```json
{
  "id": 5,
  "length_m": 8.0,
  "udl_kn_m": 15.0,
  "status": "draft"
}
```

#### Form Deflection (Submit for Review)
**Request**:
```http
PUT /api/beam_deflections/5/form
Authorization: Bearer <user_token>
```

**Response** (200 OK):
```json
{
  "message": "Beam deflection formed successfully",
  "beam_deflection": {
    "id": 5,
    "status": "formed",
    "formed_at": "2025-01-01T10:35:00Z",
    "result_deflection_mm": 12.34
  }
}
```

#### Complete Deflection (Approve)
**Request**:
```json
PUT /api/beam_deflections/5/complete
Authorization: Bearer <moderator_token>

{
  "result_deflection_mm": 12.34,
  "within_norm": true
}
```

**Response** (200 OK):
```json
{
  "message": "Beam deflection completed",
  "beam_deflection": {
    "id": 5,
    "status": "completed",
    "completed_at": "2025-01-01T11:00:00Z",
    "result_deflection_mm": 12.34,
    "within_norm": true,
    "moderator_id": 2
  }
}
```

#### Reject Deflection
**Request**:
```http
PUT /api/beam_deflections/5/reject
Authorization: Bearer <moderator_token>
```

**Response** (200 OK):
```json
{
  "message": "Beam deflection rejected",
  "beam_deflection": {
    "id": 5,
    "status": "rejected",
    "completed_at": "2025-01-01T11:00:00Z",
    "moderator_id": 2
  }
}
```

#### Cart Badge
**Request**:
```http
GET /api/beam_deflections/cart_badge
Authorization: Bearer <user_token>
```

**Response** (200 OK):
```json
{
  "count": 3
}
```

---

### Beam Deflection Items (`/api/beam_deflections/:id/items`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| PUT | `/api/beam_deflections/:id/items/update_item` | Обновить количество балки | ✅ |
| DELETE | `/api/beam_deflections/:id/items/remove_item` | Удалить балку из расчета | ✅ |

#### Update Item
**Request**:
```json
PUT /api/beam_deflections/5/items/update_item?beam_id=1
Authorization: Bearer <user_token>

{
  "quantity": 5,
  "is_primary": true
}
```

**Response** (200 OK):
```json
{
  "message": "Item updated",
  "item": {
    "beam_id": 1,
    "quantity": 5,
    "is_primary": true,
    "position": 1
  }
}
```

#### Remove Item
**Request**:
```http
DELETE /api/beam_deflections/5/items/remove_item?beam_id=1
Authorization: Bearer <user_token>
```

**Response** (200 OK):
```json
{
  "message": "Item removed from draft"
}
```

---

## Authentication & Authorization

### JWT Token Structure

```json
{
  "user_id": 1,
  "exp": 1735737600
}
```

**Характеристики**:
- Алгоритм: HS256
- Секрет: `Rails.application.credentials.secret_key_base` или `ENV['SECRET_KEY_BASE']`
- TTL: 24 часа (86400 секунд)
- Header: `Authorization: Bearer <token>`

### JWT Blacklist (Redis)

При sign out токен добавляется в Redis blacklist:

```ruby
# Key format: jwt:blacklist:<token_hash>
# Value: "1"
# TTL: время до истечения токена
```

**Проверка**:
```ruby
def decode(token)
  return nil if JwtBlacklist.blacklisted?(token)
  # ... decode logic
end
```

### Authorization Levels

1. **Public** (no auth required)
   - GET `/api/beams`
   - GET `/api/beams/:id`

2. **Authenticated User**
   - Все `/api/me` endpoints
   - POST `/api/beams/:id/add_to_draft`
   - Все `/api/beam_deflections` endpoints (с ограничениями)

3. **Moderator Only**
   - POST/PUT/DELETE `/api/beams`
   - POST `/api/beams/:id/image`
   - PUT `/api/beam_deflections/:id/complete`
   - PUT `/api/beam_deflections/:id/reject`

### Api::BaseController

```ruby
class Api::BaseController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token

    decoded = JwtToken.decode(token)
    Current.user = User.find_by(id: decoded[:user_id]) if decoded
  end

  def require_auth!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless Current.user
  end

  def require_moderator!
    require_auth!
    render json: { error: 'Forbidden' }, status: :forbidden unless Current.user.moderator?
  end
end
```

---

## Error Responses

### Standard Error Format

```json
{
  "error": "Error message",
  "details": {
    "field": ["validation error"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Успешный запрос |
| 201 | Created | Ресурс создан |
| 204 | No Content | Успешное удаление |
| 400 | Bad Request | Невалидные параметры |
| 401 | Unauthorized | Отсутствует/невалидный токен |
| 403 | Forbidden | Недостаточно прав |
| 404 | Not Found | Ресурс не найден |
| 422 | Unprocessable Entity | Ошибки валидации |
| 500 | Internal Server Error | Ошибка сервера |

### Examples

#### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

#### 403 Forbidden
```json
{
  "error": "Forbidden: Moderator access required"
}
```

#### 422 Validation Error
```json
{
  "error": "Validation failed",
  "details": {
    "length_m": ["must be greater than 0"],
    "udl_kn_m": ["can't be blank"]
  }
}
```

#### 404 Not Found
```json
{
  "error": "BeamDeflection not found"
}
```

---

## API Documentation (Swagger)

### Access Points
- **Swagger UI**: `http://localhost:3000/api-docs`
- **OpenAPI Spec**: `http://localhost:3000/api-json/v1/swagger.yaml`
- **Local File**: `swagger/v1/swagger.yaml`

### Testing with Swagger
1. Открыть `http://localhost:3000/api-docs`
2. Нажать "Authorize"
3. Ввести JWT токен: `Bearer <token>`
4. Тестировать endpoints интерактивно

### Generating Swagger Docs
```bash
# Run integration tests to generate/update docs
bundle exec rspec spec/integration/
```

---

## Rate Limiting

Currently **not implemented**. Для production рекомендуется:
- Rack::Attack для rate limiting
- Redis для хранения счетчиков
- Лимиты: 100 requests/minute для authenticated, 20/minute для anonymous

---

## Versioning

Currently: **v1** (implicit, no version in URL)

**Future**: При breaking changes использовать `/api/v2/...`

---

## CORS Configuration

**Current**: Не настроен для development (same-origin policy)

**Production**: Настроить `rack-cors`:
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://your-frontend.com'
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :delete, :options]
  end
end
```

---

## Performance Considerations

### N+1 Query Prevention
```ruby
# Good
BeamDeflection.includes(:beams, :creator).all

# Bad
deflections.each { |d| d.beams.count }
```

### Caching Strategy
- Fragment caching для списка балок
- HTTP ETag для GET endpoints
- Redis для session/JWT blacklist

### Database Indexes
Проверить наличие индексов:
```sql
CREATE INDEX idx_beam_deflections_status ON beam_deflections(status);
CREATE INDEX idx_beam_deflections_creator ON beam_deflections(creator_id);
CREATE INDEX idx_beam_deflection_beams_lookup ON beam_deflections_beams(beam_deflection_id, beam_id);
```
