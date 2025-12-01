# System Overview - Общая архитектура системы

## Высокоуровневая архитектура

```mermaid
C4Context
    title System Context Diagram - Beam Deflection Calculator

    Person(user, "User", "Создает расчеты прогиба")
    Person(moderator, "Moderator", "Проверяет и одобряет расчеты")

    System(app, "Beam Deflection Calculator", "Rails 8 приложение для расчета прогиба балок")

    System_Ext(browser, "Web Browser", "Интерфейс пользователя")
    System_Ext(api_client, "API Client", "Мобильное приложение / SPA")

    Rel(user, browser, "Использует")
    Rel(user, api_client, "Использует")
    Rel(moderator, browser, "Управляет")

    Rel(browser, app, "HTTP/HTTPS")
    Rel(api_client, app, "REST API + JWT")
```

## Компонентная архитектура

```mermaid
graph TB
    subgraph "Presentation Layer"
        WEB_UI[Web UI<br/>Views + Controllers]
        API[REST API<br/>JSON endpoints]
        SWAGGER[Swagger UI<br/>API Docs]
    end

    subgraph "Application Layer"
        AUTH[Authentication<br/>JWT + BCrypt]
        AUTHZ[Authorization<br/>Pundit]
        STATE_MACHINE[State Machine<br/>BeamDeflectionStateMachine]
        CALC[Calculation Service<br/>Calc::Deflection]
    end

    subgraph "Domain Layer"
        USER_MODEL[User]
        BEAM_MODEL[Beam]
        BD_MODEL[BeamDeflection]
        BDB_MODEL[BeamDeflectionBeam]
    end

    subgraph "Infrastructure Layer"
        POSTGRES[(PostgreSQL<br/>Primary Data)]
        REDIS[(Redis<br/>JWT Blacklist)]
        MINIO[(MinIO<br/>Images)]
    end

    subgraph "External Services"
        DOCKER[Docker Compose<br/>Orchestration]
    end

    WEB_UI --> AUTH
    API --> AUTH
    API --> SWAGGER

    AUTH --> AUTHZ
    AUTHZ --> STATE_MACHINE
    STATE_MACHINE --> BD_MODEL

    CALC --> BD_MODEL
    CALC --> BDB_MODEL

    USER_MODEL --> POSTGRES
    BEAM_MODEL --> POSTGRES
    BEAM_MODEL --> MINIO
    BD_MODEL --> POSTGRES
    BDB_MODEL --> POSTGRES

    AUTH --> REDIS
    AUTHZ --> USER_MODEL

    DOCKER -.->|Manages| POSTGRES
    DOCKER -.->|Manages| REDIS
    DOCKER -.->|Manages| MINIO
```

## Схема взаимодействия компонентов

```mermaid
sequenceDiagram
    actor User
    participant Browser
    participant API
    participant Auth
    participant Controller
    participant Service
    participant Model
    participant DB
    participant Redis
    participant MinIO

    User->>Browser: Открывает приложение
    Browser->>API: GET /api-docs

    User->>Browser: Регистрация
    Browser->>API: POST /api/auth/sign_up
    API->>Auth: Validate credentials
    Auth->>Model: User.create
    Model->>DB: INSERT users
    DB-->>Model: user
    Auth->>Auth: Generate JWT
    Auth-->>Browser: {token, user}

    User->>Browser: Просмотр балок
    Browser->>API: GET /api/beams
    API->>Controller: BeamsController#index
    Controller->>Model: Beam.active.all
    Model->>DB: SELECT * FROM beams
    DB-->>Model: beams
    Model->>MinIO: Get image URLs
    MinIO-->>Model: image_urls
    Model-->>Browser: [{id, name, image_url}]

    User->>Browser: Добавить балку в черновик
    Browser->>API: POST /api/beams/1/add_to_draft<br/>Authorization: Bearer token
    API->>Auth: Verify JWT
    Auth->>Redis: Check blacklist
    Redis-->>Auth: Not blacklisted
    Auth->>DB: Find user
    Auth-->>API: Current.user
    API->>Controller: BeamsController#add_to_draft
    Controller->>Service: Ensure draft exists
    Service->>Model: BeamDeflection.ensure_draft_for(user)
    Model->>DB: INSERT beam_deflections
    Controller->>Model: Create beam_deflection_beam
    Model->>DB: INSERT beam_deflections_beams
    DB-->>Browser: {message: "Added to draft"}

    User->>Browser: Оформить расчет
    Browser->>API: PUT /api/beam_deflections/5/form
    API->>Auth: Verify JWT
    API->>Controller: BeamDeflectionsController#form
    Controller->>Service: BeamDeflectionStateMachine
    Service->>Service: Validate transition (draft→formed)
    Service->>Model: Calculate deflection
    Model->>Model: compute_and_store_result_deflection!
    Model->>DB: UPDATE beam_deflections<br/>UPDATE beam_deflections_beams
    DB-->>Browser: {status: "formed", result: 12.34}

    actor Moderator
    Moderator->>Browser: Проверка заявок
    Browser->>API: GET /api/beam_deflections?status=formed<br/>Authorization: Bearer moderator_token
    API->>Auth: Verify JWT + moderator role
    API->>Controller: BeamDeflectionsController#index
    Controller->>Model: BeamDeflection.formed.all
    Model->>DB: SELECT * FROM beam_deflections
    DB-->>Browser: [formed deflections]

    Moderator->>Browser: Одобрить расчет
    Browser->>API: PUT /api/beam_deflections/5/complete
    API->>Auth: Require moderator
    API->>Controller: BeamDeflectionsController#complete
    Controller->>Service: BeamDeflectionStateMachine
    Service->>Service: Validate transition (formed→completed)
    Service->>Model: BeamDeflection#complete!
    Model->>DB: UPDATE beam_deflections
    DB-->>Browser: {status: "completed"}

    User->>Browser: Выход
    Browser->>API: POST /api/auth/sign_out
    API->>Auth: Blacklist token
    Auth->>Redis: SETEX jwt:blacklist:<hash>
    Redis-->>Auth: OK
    Auth-->>Browser: {message: "Signed out"}
```

## Data Flow Diagram

```mermaid
flowchart LR
    subgraph "Input"
        USER_INPUT[User Input:<br/>- Email/Password<br/>- Beam selection<br/>- Load parameters]
    end

    subgraph "Processing"
        VALIDATION[Validation:<br/>- Strong params<br/>- Model validations<br/>- State machine]
        CALCULATION[Calculation:<br/>δ = 5qL⁴/384EJ]
        AUTHORIZATION[Authorization:<br/>- JWT decode<br/>- Role check<br/>- Resource ownership]
    end

    subgraph "Storage"
        DB_WRITE[Database Write:<br/>- Users<br/>- Beams<br/>- Deflections]
        CACHE_WRITE[Redis Write:<br/>- JWT blacklist]
        FILE_WRITE[MinIO Write:<br/>- Beam images]
    end

    subgraph "Output"
        JSON_RESPONSE[JSON Response:<br/>- API results<br/>- Errors]
        HTML_RESPONSE[HTML Response:<br/>- Web views]
        FILE_RESPONSE[File Response:<br/>- Images]
    end

    USER_INPUT --> VALIDATION
    VALIDATION --> AUTHORIZATION
    AUTHORIZATION --> CALCULATION
    CALCULATION --> DB_WRITE
    AUTHORIZATION --> CACHE_WRITE
    VALIDATION --> FILE_WRITE

    DB_WRITE --> JSON_RESPONSE
    DB_WRITE --> HTML_RESPONSE
    CACHE_WRITE --> JSON_RESPONSE
    FILE_WRITE --> FILE_RESPONSE
```

## Deployment Architecture

```mermaid
graph TB
    subgraph "Host Machine"
        DOCKER_ENGINE[Docker Engine]
    end

    subgraph "Docker Network: bridge"
        subgraph "web container"
            RAILS[Rails App<br/>Port 3000]
            PUMA[Puma Server<br/>4 workers]
        end

        subgraph "db container"
            POSTGRES[PostgreSQL 15<br/>Port 5432]
            PG_VOLUME[postgres_data<br/>volume]
        end

        subgraph "redis container"
            REDIS_SERVER[Redis 7<br/>Port 6379]
            REDIS_VOLUME[redis_data<br/>volume]
        end

        subgraph "minio container"
            MINIO_SERVER[MinIO<br/>Port 9000/9001]
            MINIO_VOLUME[minio_data<br/>volume]
        end
    end

    subgraph "External Access"
        BROWSER_3000[Browser → :3000]
        BROWSER_9001[Browser → :9001]
        PSQL_CLIENT[psql → :5432]
    end

    DOCKER_ENGINE -->|Manages| RAILS
    DOCKER_ENGINE -->|Manages| POSTGRES
    DOCKER_ENGINE -->|Manages| REDIS_SERVER
    DOCKER_ENGINE -->|Manages| MINIO_SERVER

    RAILS -->|ActiveRecord| POSTGRES
    RAILS -->|JWT Blacklist| REDIS_SERVER
    RAILS -->|S3 API| MINIO_SERVER

    POSTGRES -.->|Persists| PG_VOLUME
    REDIS_SERVER -.->|AOF| REDIS_VOLUME
    MINIO_SERVER -.->|Objects| MINIO_VOLUME

    BROWSER_3000 --> RAILS
    BROWSER_9001 --> MINIO_SERVER
    PSQL_CLIENT --> POSTGRES

    style RAILS fill:#c8e6c9
    style POSTGRES fill:#bbdefb
    style REDIS_SERVER fill:#f8bbd0
    style MINIO_SERVER fill:#ffe0b2
```

## Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        subgraph "Layer 1: Transport"
            HTTPS[HTTPS/TLS<br/>SSL Certificate]
            CORS[CORS Policy<br/>Allowed Origins]
        end

        subgraph "Layer 2: Authentication"
            JWT_AUTH[JWT Authentication<br/>HS256 signed]
            BCRYPT[BCrypt Password<br/>has_secure_password]
            BLACKLIST[Redis Blacklist<br/>Revoked tokens]
        end

        subgraph "Layer 3: Authorization"
            PUNDIT[Pundit Policies<br/>Role-based]
            STATE_AUTHZ[State Machine<br/>Transition authorization]
            OWNER_CHECK[Resource Ownership<br/>creator_id check]
        end

        subgraph "Layer 4: Validation"
            STRONG_PARAMS[Strong Parameters<br/>Mass assignment protection]
            MODEL_VAL[Model Validations<br/>Business rules]
            SQL_INJECTION[SQL Injection Protection<br/>Parameterized queries]
        end

        subgraph "Layer 5: Monitoring"
            LOGS[Rails Logger<br/>Security events]
            AUDIT[Audit Trail<br/>Timestamps]
            ALERTS[Alerts<br/>Failed auth attempts]
        end
    end

    HTTPS --> JWT_AUTH
    CORS --> JWT_AUTH
    JWT_AUTH --> BCRYPT
    JWT_AUTH --> BLACKLIST

    BLACKLIST --> PUNDIT
    BCRYPT --> PUNDIT
    PUNDIT --> STATE_AUTHZ
    PUNDIT --> OWNER_CHECK

    STATE_AUTHZ --> STRONG_PARAMS
    OWNER_CHECK --> STRONG_PARAMS
    STRONG_PARAMS --> MODEL_VAL
    MODEL_VAL --> SQL_INJECTION

    SQL_INJECTION --> LOGS
    SQL_INJECTION --> AUDIT
    SQL_INJECTION --> ALERTS
```

## Technology Stack Layers

```mermaid
graph TD
    subgraph "Frontend / API Clients"
        BROWSER[Web Browser<br/>HTML + CSS + JS]
        API_CLIENT[API Clients<br/>Mobile / SPA]
        SWAGGER_UI[Swagger UI<br/>Interactive docs]
    end

    subgraph "Application Server"
        PUMA[Puma Web Server<br/>HTTP handler]
        RAILS_ROUTER[Rails Router<br/>Routes dispatcher]
        CONTROLLERS[Controllers<br/>Request handlers]
        MIDDLEWARE[Middleware Stack<br/>Auth, CORS, etc]
    end

    subgraph "Business Logic"
        MODELS[ActiveRecord Models<br/>Domain entities]
        SERVICES[Service Objects<br/>Business logic]
        CONCERNS[Concerns<br/>Shared modules]
        STATE_MACHINES[State Machines<br/>Workflow logic]
    end

    subgraph "Data Access"
        ACTIVE_RECORD[ActiveRecord ORM<br/>Database abstraction]
        REDIS_CLIENT[Redis Client<br/>Cache access]
        S3_CLIENT[AWS SDK S3<br/>Storage access]
    end

    subgraph "Infrastructure"
        POSTGRESQL_DB[(PostgreSQL<br/>Relational DB)]
        REDIS_CACHE[(Redis<br/>Key-value store)]
        MINIO_STORAGE[(MinIO<br/>Object storage)]
    end

    subgraph "DevOps Tools"
        DOCKER_COMPOSE[Docker Compose<br/>Orchestration]
        RSPEC[RSpec<br/>Testing]
        RUBOCOP[RuboCop<br/>Linting]
        BRAKEMAN[Brakeman<br/>Security]
    end

    BROWSER --> PUMA
    API_CLIENT --> PUMA
    SWAGGER_UI --> PUMA

    PUMA --> RAILS_ROUTER
    RAILS_ROUTER --> MIDDLEWARE
    MIDDLEWARE --> CONTROLLERS

    CONTROLLERS --> MODELS
    CONTROLLERS --> SERVICES
    SERVICES --> MODELS
    MODELS --> CONCERNS
    SERVICES --> STATE_MACHINES

    MODELS --> ACTIVE_RECORD
    SERVICES --> REDIS_CLIENT
    SERVICES --> S3_CLIENT

    ACTIVE_RECORD --> POSTGRESQL_DB
    REDIS_CLIENT --> REDIS_CACHE
    S3_CLIENT --> MINIO_STORAGE

    DOCKER_COMPOSE -.->|Manages| PUMA
    DOCKER_COMPOSE -.->|Manages| POSTGRESQL_DB
    DOCKER_COMPOSE -.->|Manages| REDIS_CACHE
    DOCKER_COMPOSE -.->|Manages| MINIO_STORAGE

    RSPEC -.->|Tests| MODELS
    RUBOCOP -.->|Lints| CONTROLLERS
    BRAKEMAN -.->|Scans| SERVICES
```

## Request Lifecycle

```mermaid
stateDiagram-v2
    [*] --> RequestReceived: HTTP Request

    RequestReceived --> Middleware: Rack stack
    Middleware --> AuthMiddleware: authenticate_request

    AuthMiddleware --> ExtractToken: Parse Authorization header
    ExtractToken --> DecodeToken: JwtToken.decode
    DecodeToken --> CheckBlacklist: Redis lookup

    CheckBlacklist --> TokenValid: Not blacklisted
    CheckBlacklist --> Return401: Blacklisted

    TokenValid --> FindUser: User.find_by(id)
    FindUser --> SetCurrentUser: Current.user = user

    SetCurrentUser --> RouteMatching: Rails Router
    RouteMatching --> ControllerAction: Match route

    ControllerAction --> Authorization: Check permissions
    Authorization --> Forbidden403: Insufficient rights
    Authorization --> ProcessRequest: Authorized

    ProcessRequest --> ServiceLayer: Business logic
    ServiceLayer --> ModelLayer: Domain operations
    ModelLayer --> Database: SQL queries

    Database --> ModelLayer: Results
    ModelLayer --> ServiceLayer: Processed data
    ServiceLayer --> ControllerAction: Response data

    ControllerAction --> RenderJSON: Format response
    RenderJSON --> [*]: 200 OK

    Return401 --> [*]: 401 Unauthorized
    Forbidden403 --> [*]: 403 Forbidden
```

## Scalability Considerations

### Horizontal Scaling

```mermaid
graph TB
    subgraph "Load Balancer"
        LB[Nginx / HAProxy]
    end

    subgraph "Application Tier (Stateless)"
        WEB1[Rails Instance 1]
        WEB2[Rails Instance 2]
        WEB3[Rails Instance 3]
    end

    subgraph "Database Tier (Stateful)"
        PG_PRIMARY[(PostgreSQL Primary)]
        PG_REPLICA1[(PostgreSQL Replica 1)]
        PG_REPLICA2[(PostgreSQL Replica 2)]
    end

    subgraph "Cache Tier"
        REDIS_MASTER[(Redis Master)]
        REDIS_REPLICA[(Redis Replica)]
    end

    subgraph "Storage Tier"
        MINIO_CLUSTER[MinIO Distributed<br/>4+ nodes]
    end

    LB --> WEB1
    LB --> WEB2
    LB --> WEB3

    WEB1 --> PG_PRIMARY
    WEB2 --> PG_REPLICA1
    WEB3 --> PG_REPLICA2

    WEB1 --> REDIS_MASTER
    WEB2 --> REDIS_MASTER
    WEB3 --> REDIS_MASTER

    REDIS_MASTER -.->|Replication| REDIS_REPLICA

    PG_PRIMARY -.->|Streaming replication| PG_REPLICA1
    PG_PRIMARY -.->|Streaming replication| PG_REPLICA2

    WEB1 --> MINIO_CLUSTER
    WEB2 --> MINIO_CLUSTER
    WEB3 --> MINIO_CLUSTER

    style WEB1 fill:#c8e6c9
    style WEB2 fill:#c8e6c9
    style WEB3 fill:#c8e6c9
```

### Performance Bottlenecks

| Component | Potential Bottleneck | Mitigation |
|-----------|---------------------|------------|
| **Rails App** | Ruby GIL (Global Interpreter Lock) | Use Puma threads, horizontal scaling |
| **PostgreSQL** | Write locks on `beam_deflections` | Read replicas for SELECT, partition large tables |
| **Redis** | Single-threaded nature | Use Redis Cluster for sharding |
| **MinIO** | Network I/O for large images | CDN caching, image optimization |
| **JWT Decode** | CPU-intensive on every request | Redis caching of decoded tokens (short TTL) |

### Monitoring Metrics

```mermaid
graph LR
    subgraph "Application Metrics"
        REQ_RATE[Request Rate<br/>req/sec]
        RES_TIME[Response Time<br/>p50, p95, p99]
        ERROR_RATE[Error Rate<br/>5xx errors]
    end

    subgraph "Infrastructure Metrics"
        CPU[CPU Usage<br/>per container]
        MEMORY[Memory Usage<br/>per container]
        DISK[Disk I/O<br/>IOPS]
    end

    subgraph "Business Metrics"
        USERS[Active Users<br/>Daily/Monthly]
        DEFLECTIONS[Deflections Created<br/>per day]
        APPROVAL_RATE[Approval Rate<br/>%]
    end

    subgraph "Security Metrics"
        FAILED_AUTH[Failed Auth<br/>attempts]
        BLACKLIST_SIZE[Blacklist Size<br/>keys count]
        TOKEN_REUSE[Token Reuse<br/>attempts]
    end

    REQ_RATE -.->|Alert if > 1000| ALERT[Alert System]
    RES_TIME -.->|Alert if > 500ms| ALERT
    ERROR_RATE -.->|Alert if > 1%| ALERT
    FAILED_AUTH -.->|Alert if > 10/min| ALERT
```

## Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Environment** | Docker Compose | Kubernetes / ECS |
| **Database** | PostgreSQL (single instance) | PostgreSQL (primary + replicas) |
| **Redis** | Single instance | Redis Cluster / Sentinel |
| **MinIO** | Single container | Distributed mode (4+ nodes) |
| **SSL** | Optional (localhost) | Required (Let's Encrypt) |
| **Secrets** | .env file | Docker secrets / Vault |
| **Logging** | STDOUT | Centralized (ELK, CloudWatch) |
| **Monitoring** | Manual | Prometheus + Grafana |
| **Backups** | Manual pg_dump | Automated (daily + hourly) |
| **CDN** | None | CloudFlare / CloudFront |
| **Rate Limiting** | None | Rack::Attack + WAF |

---

## Glossary

| Term | Definition |
|------|------------|
| **Beam** | Конструктивный элемент (балка) с физическими характеристиками |
| **Deflection** | Прогиб балки под нагрузкой (δ, mm) |
| **UDL** | Uniformly Distributed Load - равномерно распределенная нагрузка (q, kN/m) |
| **Elasticity** | Модуль упругости материала (E, GPa) |
| **Inertia** | Момент инерции сечения балки (J, cm⁴) |
| **State Machine** | Конечный автомат для управления статусами расчета |
| **JWT** | JSON Web Token - токен аутентификации |
| **Blacklist** | Список отозванных токенов в Redis |
| **MinIO** | S3-compatible объектное хранилище |
| **AOF** | Append-Only File - механизм персистентности Redis |

---

## Next Steps

### Immediate Improvements
1. Добавить rate limiting (Rack::Attack)
2. Настроить CORS для production
3. Добавить background jobs (Sidekiq + Redis)
4. Реализовать email notifications (Action Mailer)

### Future Features
1. Расширенные расчеты (точечные нагрузки, многопролетные балки)
2. Графики прогиба (Chart.js)
3. Экспорт результатов (PDF, Excel)
4. История изменений расчета (PaperTrail gem)
5. Комментарии к расчетам
6. Webhooks для интеграций

### Performance Optimizations
1. Fragment caching для списков
2. Database connection pooling
3. Eager loading (N+1 prevention)
4. CDN для статических файлов
5. Gzip compression

---

Эта диаграмма предоставляет полное видение системы на разных уровнях абстракции.
