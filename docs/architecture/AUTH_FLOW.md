# Authentication & Authorization Flow

## Обзор системы аутентификации

Приложение использует **JWT (JSON Web Token)** аутентификацию с blacklist механизмом через Redis для безопасного logout.

## Архитектура компонентов

```mermaid
graph TB
    subgraph "Client"
        CLIENT[Web/Mobile Client]
    end

    subgraph "API Layer"
        AUTH_CTRL[AuthController]
        BASE_CTRL[Api::BaseController]
    end

    subgraph "Security Services"
        JWT_TOKEN[JwtToken Service]
        JWT_BLACKLIST[JwtBlacklist Service]
        BCRYPT[BCrypt has_secure_password]
    end

    subgraph "Storage"
        REDIS[(Redis<br/>JWT Blacklist)]
        POSTGRES[(PostgreSQL<br/>Users)]
    end

    subgraph "Request Context"
        CURRENT[Current.user<br/>Thread-safe context]
    end

    CLIENT -->|1. POST /sign_up| AUTH_CTRL
    CLIENT -->|2. POST /sign_in| AUTH_CTRL
    CLIENT -->|3. Request + Bearer token| BASE_CTRL
    CLIENT -->|4. POST /sign_out| AUTH_CTRL

    AUTH_CTRL --> BCRYPT
    AUTH_CTRL --> JWT_TOKEN
    AUTH_CTRL --> JWT_BLACKLIST

    BASE_CTRL --> JWT_TOKEN
    BASE_CTRL --> CURRENT

    JWT_TOKEN --> JWT_BLACKLIST
    JWT_BLACKLIST --> REDIS
    BCRYPT --> POSTGRES
    JWT_TOKEN --> POSTGRES

    CURRENT -.->|Available in controllers| BASE_CTRL
```

## Последовательность аутентификации

### 1. Sign Up (Регистрация)

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant AuthController
    participant User Model
    participant BCrypt
    participant JwtToken
    participant PostgreSQL

    User->>Client: Заполняет форму регистрации
    Client->>AuthController: POST /api/auth/sign_up<br/>{email, password, password_confirmation}

    AuthController->>User Model: User.new(params)
    User Model->>User Model: validates :email, uniqueness: true
    User Model->>User Model: validates :password, length: {minimum: 6}

    User Model->>BCrypt: has_secure_password
    BCrypt->>BCrypt: Generate password_digest

    User Model->>PostgreSQL: INSERT INTO users
    PostgreSQL-->>User Model: user (id: 1)

    User Model-->>AuthController: user
    AuthController->>JwtToken: encode(user_id: 1, exp: 24h)
    JwtToken-->>AuthController: token

    AuthController-->>Client: 201 Created<br/>{token, user}
    Client->>Client: Store token in localStorage
    Client-->>User: Успешная регистрация
```

**Request**:
```http
POST /api/auth/sign_up
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "moderator": false
}
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzU4MjQwMDB9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "moderator": false,
    "created_at": "2025-01-01T10:00:00Z"
  }
}
```

**Код**:
```ruby
# app/controllers/api/auth_controller.rb
def sign_up
  user = User.new(sign_up_params)

  if user.save
    token = JwtToken.encode(user_id: user.id)
    render json: { token: token, user: user }, status: :created
  else
    render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
  end
end
```

---

### 2. Sign In (Вход)

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant AuthController
    participant User Model
    participant BCrypt
    participant JwtToken
    participant PostgreSQL

    User->>Client: Вводит email и password
    Client->>AuthController: POST /api/auth/sign_in<br/>{email, password}

    AuthController->>PostgreSQL: User.find_by(email: ...)
    PostgreSQL-->>User Model: user

    User Model->>BCrypt: authenticate(password)
    BCrypt-->>User Model: true/false

    alt Valid credentials
        User Model-->>AuthController: user
        AuthController->>JwtToken: encode(user_id: user.id)
        JwtToken-->>AuthController: token
        AuthController-->>Client: 200 OK<br/>{token, user}
        Client->>Client: Store token
        Client-->>User: Успешный вход
    else Invalid credentials
        AuthController-->>Client: 401 Unauthorized<br/>{error: "Invalid credentials"}
        Client-->>User: Ошибка входа
    end
```

**Request**:
```http
POST /api/auth/sign_in
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzU4MjQwMDB9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "moderator": false
  }
}
```

**Код**:
```ruby
def sign_in
  user = User.find_by(email: params[:email])

  if user&.authenticate(params[:password])
    token = JwtToken.encode(user_id: user.id)
    render json: { token: token, user: user }, status: :ok
  else
    render json: { error: 'Invalid credentials' }, status: :unauthorized
  end
end
```

---

### 3. Authenticated Request

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant Api::BaseController
    participant JwtToken
    participant JwtBlacklist
    participant Redis
    participant PostgreSQL
    participant Current
    participant Resource Controller

    User->>Client: Запрос к защищенному ресурсу
    Client->>Api::BaseController: GET /api/me<br/>Authorization: Bearer <token>

    Api::BaseController->>Api::BaseController: before_action :authenticate_request
    Api::BaseController->>Api::BaseController: Extract token from header

    Api::BaseController->>JwtToken: decode(token)
    JwtToken->>JwtToken: Hash token (SHA256)
    JwtToken->>JwtBlacklist: blacklisted?(token_hash)
    JwtBlacklist->>Redis: EXISTS jwt:blacklist:<hash>

    alt Token in blacklist
        Redis-->>JwtBlacklist: true
        JwtBlacklist-->>JwtToken: true
        JwtToken-->>Api::BaseController: nil
        Api::BaseController-->>Client: 401 Unauthorized
    else Token valid
        Redis-->>JwtBlacklist: false
        JwtBlacklist-->>JwtToken: false
        JwtToken->>JwtToken: JWT.decode(token, secret)
        JwtToken-->>Api::BaseController: {user_id: 1, exp: ...}

        Api::BaseController->>PostgreSQL: User.find_by(id: 1)
        PostgreSQL-->>Api::BaseController: user

        Api::BaseController->>Current: Current.user = user
        Current-->>Api::BaseController: user set

        Api::BaseController->>Resource Controller: Continue request
        Resource Controller->>Resource Controller: Process with Current.user
        Resource Controller-->>Client: 200 OK + Response
    end
```

**Request**:
```http
GET /api/me
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Код**:
```ruby
# app/controllers/api/base_controller.rb
class Api::BaseController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token

    decoded = JwtToken.decode(token)
    Current.user = User.find_by(id: decoded[:user_id]) if decoded
  rescue => e
    Rails.logger.error "Authentication error: #{e.message}"
    nil
  end

  def require_auth!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless Current.user
  end

  def require_moderator!
    require_auth!
    unless Current.user&.moderator?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end
```

---

### 4. Sign Out (Выход с Blacklist)

```mermaid
sequenceDiagram
    actor User
    participant Client
    participant AuthController
    participant JwtToken
    participant JwtBlacklist
    participant Redis

    User->>Client: Нажимает "Выход"
    Client->>AuthController: POST /api/auth/sign_out<br/>Authorization: Bearer <token>

    AuthController->>AuthController: Extract token
    AuthController->>JwtToken: blacklist!(token)

    JwtToken->>JwtToken: decode(token) to get exp
    JwtToken->>JwtToken: hash_token(token)

    JwtToken->>JwtBlacklist: add(token_hash, ttl)
    JwtBlacklist->>Redis: SETEX jwt:blacklist:<hash> <ttl> "1"
    Redis-->>JwtBlacklist: OK

    JwtBlacklist-->>JwtToken: true
    JwtToken-->>AuthController: true

    AuthController-->>Client: 200 OK<br/>{message: "Successfully signed out"}
    Client->>Client: Remove token from localStorage
    Client-->>User: Выход выполнен
```

**Request**:
```http
POST /api/auth/sign_out
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response**:
```json
{
  "message": "Successfully signed out"
}
```

**Код**:
```ruby
# app/controllers/api/auth_controller.rb
def sign_out
  token = request.headers['Authorization']&.split(' ')&.last

  if token && JwtToken.blacklist!(token)
    render json: { message: 'Successfully signed out' }, status: :ok
  else
    render json: { error: 'Failed to sign out' }, status: :unprocessable_entity
  end
end

# app/lib/jwt_token.rb
def self.blacklist!(token)
  decoded = decode(token)
  return false unless decoded

  ttl = decoded[:exp] - Time.now.to_i
  return true if ttl <= 0 # Already expired

  token_hash = hash_token(token)
  JwtBlacklist.add(token_hash, ttl)
end
```

---

## JWT Token Service

### Структура токена

```ruby
# Payload
{
  user_id: 1,
  exp: 1735824000  # 24 hours from now
}

# Header
{
  alg: "HS256",
  typ: "JWT"
}
```

### JwtToken класс

```ruby
# app/lib/jwt_token.rb
class JwtToken
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE']
  EXPIRATION_TIME = 24.hours.to_i

  def self.encode(payload, exp = EXPIRATION_TIME.from_now.to_i)
    payload[:exp] = exp
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    return nil if JwtBlacklist.blacklisted?(hash_token(token))

    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError
    nil
  end

  def self.blacklist!(token)
    decoded = decode(token)
    return false unless decoded

    ttl = decoded[:exp] - Time.now.to_i
    return true if ttl <= 0

    token_hash = hash_token(token)
    JwtBlacklist.add(token_hash, ttl)
  end

  def self.hash_token(token)
    Digest::SHA256.hexdigest(token)
  end
end
```

---

## JWT Blacklist Service

### Архитектура

```mermaid
graph LR
    subgraph "JwtBlacklist Service"
        ADD[add token_hash, ttl]
        CHECK[blacklisted? token_hash]
        CLEANUP[Auto-cleanup via TTL]
    end

    subgraph "Redis Storage"
        KEY1[jwt:blacklist:abc123<br/>value: "1"<br/>TTL: 86400s]
        KEY2[jwt:blacklist:def456<br/>value: "1"<br/>TTL: 43200s]
    end

    ADD --> KEY1
    CHECK --> KEY1
    CHECK --> KEY2
    CLEANUP -.->|Redis auto-expires| KEY1
```

### JwtBlacklist класс

```ruby
# app/services/jwt_blacklist.rb
class JwtBlacklist
  REDIS_KEY_PREFIX = 'jwt:blacklist:'

  def self.add(token_hash, ttl)
    redis.setex("#{REDIS_KEY_PREFIX}#{token_hash}", ttl, '1')
    true
  rescue => e
    Rails.logger.error "Failed to blacklist token: #{e.message}"
    false
  end

  def self.blacklisted?(token_hash)
    redis.exists?("#{REDIS_KEY_PREFIX}#{token_hash}")
  rescue => e
    Rails.logger.error "Failed to check blacklist: #{e.message}"
    false  # Fail-open for availability
  end

  def self.redis
    Rails.application.config.redis
  end
end
```

### Redis Configuration

```ruby
# config/initializers/redis.rb
Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  timeout: 5,
  reconnect_attempts: 3
)
```

**Docker Compose**:
```yaml
redis:
  image: redis:7-alpine
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
  command: redis-server --appendonly yes
```

---

## Authorization (Roles & Permissions)

### Иерархия ролей

```mermaid
graph TD
    PUBLIC[Public/Anonymous]
    USER[Authenticated User]
    MODERATOR[Moderator]

    PUBLIC -->|Can read| BEAMS[Beams catalog]
    USER -->|Can create| DRAFTS[Draft calculations]
    USER -->|Can view own| OWN_CALCS[Own calculations]
    MODERATOR -->|Can manage| ALL_BEAMS[All beams CRUD]
    MODERATOR -->|Can approve/reject| ALL_CALCS[All formed calculations]

    PUBLIC -.->|sign_up/sign_in| USER
    USER -.->|moderator flag| MODERATOR
```

### Матрица прав доступа

| Ресурс | Action | Public | User | Moderator |
|--------|--------|--------|------|-----------|
| **Beams** |
| List beams | GET /beams | ✅ | ✅ | ✅ |
| View beam | GET /beams/:id | ✅ | ✅ | ✅ |
| Create beam | POST /beams | ❌ | ❌ | ✅ |
| Update beam | PUT /beams/:id | ❌ | ❌ | ✅ |
| Delete beam | DELETE /beams/:id | ❌ | ❌ | ✅ |
| Upload image | POST /beams/:id/image | ❌ | ❌ | ✅ |
| Add to draft | POST /beams/:id/add_to_draft | ❌ | ✅ | ✅ |
| **Beam Deflections** |
| List deflections | GET /beam_deflections | ❌ | ✅ (own) | ✅ (all) |
| View deflection | GET /beam_deflections/:id | ❌ | ✅ (own) | ✅ (all) |
| Update deflection | PUT /beam_deflections/:id | ❌ | ✅ (draft only) | ❌ |
| Delete deflection | DELETE /beam_deflections/:id | ❌ | ✅ (draft only) | ❌ |
| Form deflection | PUT /beam_deflections/:id/form | ❌ | ✅ (creator) | ❌ |
| Complete deflection | PUT /beam_deflections/:id/complete | ❌ | ❌ | ✅ |
| Reject deflection | PUT /beam_deflections/:id/reject | ❌ | ❌ | ✅ |
| **User Profile** |
| View profile | GET /me | ❌ | ✅ (own) | ✅ (own) |
| Update profile | PUT /me | ❌ | ✅ (own) | ✅ (own) |

### Authorization Helpers

```ruby
# app/controllers/api/base_controller.rb
def require_auth!
  render json: { error: 'Unauthorized' }, status: :unauthorized unless Current.user
end

def require_moderator!
  require_auth!
  unless Current.user&.moderator?
    render json: { error: 'Forbidden: Moderator access required' },
           status: :forbidden
  end
end

def authorize_resource_owner!(resource)
  require_auth!
  unless resource.creator_id == Current.user.id || Current.user.moderator?
    render json: { error: 'Forbidden: Not the resource owner' },
           status: :forbidden
  end
end
```

### Model-level Authorization

```ruby
# app/models/beam_deflection.rb
def can_form_by?(user)
  creator == user && draft?
end

def can_complete_by?(user)
  user.moderator? && formed?
end

def can_reject_by?(user)
  user.moderator? && formed?
end
```

---

## Security Best Practices

### ✅ Implemented

1. **Password Hashing** - BCrypt через `has_secure_password`
2. **JWT with Expiration** - 24h TTL
3. **Token Blacklist** - Redis-based invalidation
4. **HTTPS Only (Production)** - Force SSL в production
5. **Thread-safe Context** - `Current.user` через ActiveSupport::CurrentAttributes
6. **SQL Injection Protection** - ActiveRecord параметризованные запросы
7. **Mass Assignment Protection** - Strong parameters

### ⚠️ Recommendations

1. **Rate Limiting** - добавить Rack::Attack
   ```ruby
   Rack::Attack.throttle('auth/ip', limit: 5, period: 60.seconds) do |req|
     req.ip if req.path == '/api/auth/sign_in'
   end
   ```

2. **Password Complexity** - усилить валидацию
   ```ruby
   validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}\z/ }
   ```

3. **2FA** - добавить двухфакторную аутентификацию

4. **Session Fixation** - ротация токенов при смене пароля

5. **CORS** - настроить разрешенные origins
   ```ruby
   Rails.application.config.middleware.insert_before 0, Rack::Cors do
     allow do
       origins 'https://trusted-domain.com'
       resource '/api/*', headers: :any, methods: [:get, :post, :put, :delete]
     end
   end
   ```

6. **CSP Headers** - Content Security Policy

7. **Audit Logging** - логировать все аутентификационные события

---

## Troubleshooting

### Common Issues

#### 1. Token Always Returns 401
**Причина**: Токен в blacklist или истек

**Решение**:
```bash
# Проверить Redis
docker-compose exec redis redis-cli
> KEYS jwt:blacklist:*
> TTL jwt:blacklist:<hash>

# Проверить expiration
irb> JwtToken.decode('<token>')
```

#### 2. Redis Connection Failed
**Причина**: Redis недоступен

**Решение**:
```bash
docker-compose up redis
# Проверить REDIS_URL в .env
```

#### 3. "Signature Verification Failed"
**Причина**: Несоответствие SECRET_KEY_BASE

**Решение**:
```bash
# Проверить SECRET_KEY_BASE
echo $SECRET_KEY_BASE
# Или в Rails credentials
rails credentials:edit
```

#### 4. Moderator Cannot Access Resource
**Причина**: `moderator` flag не установлен

**Решение**:
```ruby
# Rails console
user = User.find_by(email: 'admin@example.com')
user.update!(moderator: true)
```

---

## Testing Authentication

### RSpec Examples

```ruby
# spec/support/auth_helper.rb
module AuthHelper
  def sign_in(user)
    token = JwtToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
end

# spec/requests/api/beams_spec.rb
RSpec.describe 'Api::Beams', type: :request do
  let(:user) { create(:user) }
  let(:moderator) { create(:user, moderator: true) }

  describe 'POST /api/beams' do
    context 'as moderator' do
      it 'creates a beam' do
        post '/api/beams',
             params: { name: 'Test Beam' },
             headers: sign_in(moderator)
        expect(response).to have_http_status(:created)
      end
    end

    context 'as regular user' do
      it 'returns forbidden' do
        post '/api/beams',
             params: { name: 'Test Beam' },
             headers: sign_in(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

---

## Monitoring & Metrics

### Key Metrics to Track

1. **Authentication Success Rate**
   ```ruby
   successful_logins / total_login_attempts * 100
   ```

2. **Token Blacklist Size**
   ```bash
   redis-cli DBSIZE
   ```

3. **Average Token Lifetime**
   ```ruby
   (Time.now - user.last_sign_in_at).in_hours
   ```

4. **Failed Authentication Attempts**
   ```ruby
   Rails.logger.warn "Failed login attempt: #{params[:email]}"
   ```
