# Индекс документации - Beam Deflection Calculator

## Навигация по документации

Этот индекс поможет быстро найти нужную информацию в технической документации проекта.

---

## 📚 Основная документация

### [README](README.md)
**Главная точка входа в документацию**
- Обзор проекта и технологического стека
- Быстрый старт и установка
- Архитектурные решения
- Бизнес-логика расчетов
- Тестирование и deployment

---

## 🏗️ Архитектурная документация

### [1. System Overview](architecture/SYSTEM_OVERVIEW.md)
**Общая архитектура всей системы**

**Содержание**:
- Высокоуровневая архитектура (C4 Context)
- Компонентная архитектура
- Схема взаимодействия компонентов (sequence diagrams)
- Data Flow Diagram
- Deployment Architecture
- Security Architecture
- Technology Stack Layers
- Request Lifecycle
- Scalability Considerations
- Development vs Production

**Для кого**:
- Архитекторы
- Tech Leads
- DevOps инженеры
- Новые разработчики (onboarding)

---

### [2. Entity-Relationship Diagram (ERD)](architecture/ERD.md)
**Схема базы данных**

**Содержание**:
- Mermaid ERD диаграмма
- Описание каждой сущности (User, Beam, BeamDeflection, BeamDeflectionBeam)
- Поля, типы данных, ограничения
- Foreign keys и индексы
- Check constraints
- Формула расчета прогиба
- Статистика таблиц

**Для кого**:
- Backend разработчики
- Database администраторы
- Data analysts

**Ключевые секции**:
- `## Диаграмма базы данных` - визуальная схема
- `## Описание сущностей` - детали по каждой таблице
- `## Индексы и ограничения` - production оптимизации

---

### [3. State Machine Diagram](architecture/STATE_MACHINE.md)
**Жизненный цикл расчетов прогиба**

**Содержание**:
- Mermaid state diagram
- Описание 5 состояний (draft, formed, completed, rejected, deleted)
- Матрица переходов
- Авторизация переходов (роли)
- Методы модели
- Scopes для запросов
- Бизнес-правила
- Примеры использования
- Обработка ошибок
- Мониторинг метрик

**Для кого**:
- Backend разработчики
- QA инженеры
- Product owners

**Ключевые секции**:
- `## Диаграмма состояний` - визуальный workflow
- `## Матрица переходов` - таблица разрешенных переходов
- `## Авторизация переходов` - кто может делать что
- `## Примеры использования` - Ruby код

---

### [4. API Architecture](architecture/API_ARCHITECTURE.md)
**RESTful JSON API документация**

**Содержание**:
- Архитектурная диаграмма API
- Полный список endpoints с примерами
- Authentication (`/api/auth`)
- Current User (`/api/me`)
- Beams CRUD (`/api/beams`)
- Beam Deflections (`/api/beam_deflections`)
- Beam Deflection Items
- Request/Response форматы
- Error responses (коды и форматы)
- Swagger documentation
- Rate limiting (рекомендации)
- CORS configuration
- Performance considerations

**Для кого**:
- Backend разработчики
- Frontend/Mobile разработчики
- API consumers
- Technical writers

**Ключевые секции**:
- `## API Endpoints` - детальное описание каждого endpoint
- `## Authentication & Authorization` - JWT структура
- `## Error Responses` - стандартные ошибки
- `## Swagger UI` - интерактивная документация

**Примеры запросов**:
```bash
# Sign up
POST /api/auth/sign_up

# Add to draft
POST /api/beams/1/add_to_draft

# Form deflection
PUT /api/beam_deflections/5/form

# Complete (moderator)
PUT /api/beam_deflections/5/complete
```

---

### [5. Authentication & Authorization Flow](architecture/AUTH_FLOW.md)
**Система безопасности**

**Содержание**:
- Архитектура аутентификации (Mermaid diagrams)
- JWT Token Service
- JWT Blacklist Service (Redis)
- Sequence diagrams для:
  - Sign Up
  - Sign In
  - Authenticated Request
  - Sign Out (с blacklist)
- Матрица прав доступа (Public / User / Moderator)
- Security best practices
- Troubleshooting
- Testing authentication

**Для кого**:
- Security engineers
- Backend разработчики
- DevOps инженеры

**Ключевые секции**:
- `## Последовательность аутентификации` - 4 sequence diagrams
- `## JWT Token Service` - структура и код
- `## JWT Blacklist Service` - Redis integration
- `## Authorization (Roles & Permissions)` - матрица доступа
- `## Security Best Practices` - рекомендации

**Важные концепции**:
- JWT с 24h TTL
- Redis blacklist для logout
- BCrypt для паролей
- Current.user thread-safe context

---

### [6. Docker Architecture](architecture/DOCKER_ARCHITECTURE.md)
**Инфраструктура Docker Compose**

**Содержание**:
- Архитектурная диаграмма Docker
- Детальная схема 4 сервисов:
  - **web** (Rails + Puma)
  - **db** (PostgreSQL 15)
  - **redis** (Redis 7 + AOF)
  - **minio** (MinIO S3)
- docker-compose.yml анализ
- Environment variables
- Volumes management
- Docker networking
- Development workflow
- Production considerations
- Troubleshooting guide

**Для кого**:
- DevOps инженеры
- Backend разработчики
- System administrators

**Ключевые секции**:
- `## docker-compose.yml Анализ` - полная конфигурация
- `## Сервис: Web` - Rails application setup
- `## Сервис: PostgreSQL` - database configuration
- `## Сервис: Redis` - JWT blacklist + AOF
- `## Сервис: MinIO` - S3 storage
- `## Development Workflow` - команды для разработки
- `## Troubleshooting` - решение проблем

**Полезные команды**:
```bash
# Start
docker-compose up

# Migrations
docker-compose exec web bin/rails db:migrate

# Console
docker-compose exec web bin/rails console

# Tests
docker-compose exec web bundle exec rspec

# Logs
docker-compose logs -f web
```

---

## 🔍 Как найти информацию

### По теме

| Тема | Документ | Секция |
|------|----------|--------|
| **Database schema** | ERD.md | "Описание сущностей" |
| **API endpoints** | API_ARCHITECTURE.md | "API Endpoints" |
| **JWT authentication** | AUTH_FLOW.md | "JWT Token Service" |
| **State transitions** | STATE_MACHINE.md | "Матрица переходов" |
| **Docker setup** | DOCKER_ARCHITECTURE.md | "docker-compose.yml" |
| **Environment variables** | DOCKER_ARCHITECTURE.md | "Environment Variables" |
| **Error handling** | API_ARCHITECTURE.md | "Error Responses" |
| **Security practices** | AUTH_FLOW.md | "Security Best Practices" |
| **Scalability** | SYSTEM_OVERVIEW.md | "Scalability Considerations" |
| **Testing** | README.md | "Тестирование" |
| **Deployment** | README.md | "Production Deployment" |

---

### По роли

#### Для Backend разработчика
1. [System Overview](architecture/SYSTEM_OVERVIEW.md) - общая картина
2. [ERD](architecture/ERD.md) - database schema
3. [State Machine](architecture/STATE_MACHINE.md) - business logic
4. [API Architecture](architecture/API_ARCHITECTURE.md) - endpoint implementation
5. [README](README.md) - testing и workflow

#### Для Frontend разработчика
1. [API Architecture](architecture/API_ARCHITECTURE.md) - все endpoints
2. [Auth Flow](architecture/AUTH_FLOW.md) - JWT implementation
3. [System Overview](architecture/SYSTEM_OVERVIEW.md) - request lifecycle

#### Для DevOps инженера
1. [Docker Architecture](architecture/DOCKER_ARCHITECTURE.md) - infrastructure
2. [System Overview](architecture/SYSTEM_OVERVIEW.md) - deployment architecture
3. [README](README.md) - production considerations

#### Для QA инженера
1. [State Machine](architecture/STATE_MACHINE.md) - workflow testing
2. [API Architecture](architecture/API_ARCHITECTURE.md) - endpoint testing
3. [Auth Flow](architecture/AUTH_FLOW.md) - security testing

#### Для нового разработчика (Onboarding)
1. [README](README.md) - start here
2. [System Overview](architecture/SYSTEM_OVERVIEW.md) - big picture
3. [ERD](architecture/ERD.md) - understand data model
4. [Docker Architecture](architecture/DOCKER_ARCHITECTURE.md) - local setup
5. [API Architecture](architecture/API_ARCHITECTURE.md) - try Swagger UI

---

## 📊 Диаграммы и визуализации

### Mermaid диаграммы

Все диаграммы созданы с использованием Mermaid.js и рендерятся в GitHub/GitLab:

| Тип диаграммы | Документ | Название |
|---------------|----------|----------|
| **ERD** | ERD.md | Entity-Relationship Diagram |
| **State Diagram** | STATE_MACHINE.md | BeamDeflection States |
| **Architecture** | API_ARCHITECTURE.md | API Architecture |
| **Sequence** | AUTH_FLOW.md | Authentication Flows (4 diagrams) |
| **Component** | SYSTEM_OVERVIEW.md | Component Architecture |
| **Deployment** | DOCKER_ARCHITECTURE.md | Docker Services |
| **C4 Context** | SYSTEM_OVERVIEW.md | System Context |
| **Data Flow** | SYSTEM_OVERVIEW.md | Data Flow Diagram |
| **Security** | SYSTEM_OVERVIEW.md | Security Layers |

### Просмотр диаграмм

**В GitHub/GitLab**: Mermaid рендерится автоматически

**Локально**:
- VS Code: установить "Markdown Preview Mermaid Support"
- Online: скопировать код в https://mermaid.live/

---

## 🔧 Code Examples

### Модели

**Файлы**:
- `app/models/user.rb`
- `app/models/beam.rb`
- `app/models/beam_deflection.rb`
- `app/models/beam_deflection_beam.rb`

**Описание**: [ERD.md](architecture/ERD.md)

### Контроллеры

**Файлы**:
- `app/controllers/api/auth_controller.rb`
- `app/controllers/api/beams_controller.rb`
- `app/controllers/api/beam_deflections_controller.rb`

**Описание**: [API_ARCHITECTURE.md](architecture/API_ARCHITECTURE.md)

### Сервисы

**Файлы**:
- `app/services/beam_deflection_state_machine.rb`
- `app/services/jwt_blacklist.rb`
- `app/lib/jwt_token.rb`

**Описание**: [STATE_MACHINE.md](architecture/STATE_MACHINE.md), [AUTH_FLOW.md](architecture/AUTH_FLOW.md)

### Конфигурация

**Файлы**:
- `docker-compose.yml`
- `config/routes.rb`
- `config/database.yml`
- `config/initializers/redis.rb`

**Описание**: [DOCKER_ARCHITECTURE.md](architecture/DOCKER_ARCHITECTURE.md)

---

## 🧪 Testing & Examples

### Unit Tests
```bash
# Модели
docker-compose exec web bundle exec rspec spec/models/

# Сервисы
docker-compose exec web bundle exec rspec spec/services/
```

### Integration Tests
```bash
# API endpoints (генерирует Swagger)
docker-compose exec web bundle exec rspec spec/integration/
```

### Manual Testing
```bash
# Swagger UI
http://localhost:3000/api-docs

# curl примеры в:
# - API_ARCHITECTURE.md
# - AUTH_FLOW.md
```

**Документация**: [README.md#Тестирование](README.md)

---

## 🚀 Quick Links

### Development
- [Быстрый старт](README.md#Быстрый-старт)
- [Docker commands](architecture/DOCKER_ARCHITECTURE.md#Development-Workflow)
- [Troubleshooting](architecture/DOCKER_ARCHITECTURE.md#Troubleshooting)

### API Reference
- [Swagger UI](http://localhost:3000/api-docs) (local)
- [API Endpoints](architecture/API_ARCHITECTURE.md#API-Endpoints)
- [Authentication](architecture/AUTH_FLOW.md)

### Production
- [Deployment Guide](README.md#Production-Deployment)
- [Security Best Practices](architecture/AUTH_FLOW.md#Security-Best-Practices)
- [Scalability](architecture/SYSTEM_OVERVIEW.md#Scalability-Considerations)

---

## 📝 Documentation Standards

### Формат файлов
- **Markdown** (.md) для всех документов
- **Mermaid** для диаграмм
- **YAML** для конфигураций

### Структура документа
1. **Заголовок** (H1)
2. **Содержание** (опционально для больших файлов)
3. **Введение** - что, зачем, для кого
4. **Основной контент** - секции с H2-H4
5. **Примеры** - code blocks с подсветкой синтаксиса
6. **Ссылки** - внутренние и внешние

### Naming Conventions
- Файлы: `UPPERCASE_WITH_UNDERSCORES.md`
- Папки: `lowercase-with-dashes/`
- Якоря: `#lowercase-with-dashes`

---

## 🔄 Обновление документации

### Когда обновлять

| Изменение в коде | Обновить документ |
|------------------|-------------------|
| Новая/изменена таблица БД | ERD.md |
| Новый/изменен endpoint | API_ARCHITECTURE.md |
| Новый статус/переход | STATE_MACHINE.md |
| Изменение auth логики | AUTH_FLOW.md |
| Новый Docker сервис | DOCKER_ARCHITECTURE.md |
| Изменение архитектуры | SYSTEM_OVERVIEW.md |
| Breaking change | README.md + соотв. файл |

### Workflow
1. Внести изменения в код
2. Обновить соответствующий .md файл
3. Проверить Mermaid диаграммы (https://mermaid.live/)
4. Обновить INDEX.md (если добавлена новая секция)
5. Commit с сообщением: `docs: update <FILE> for <FEATURE>`

---

## 💡 Contributing to Docs

### Принципы
- **Ясность** > краткость
- **Примеры** > абстрактные описания
- **Визуализация** > текст (где возможно)
- **Актуальность** - удалять устаревшее

### Checklist для нового документа
- [ ] Создан в правильной папке (`docs/` или `docs/architecture/`)
- [ ] Добавлен в этот INDEX.md
- [ ] Добавлен в README.md (если важный)
- [ ] Содержит Mermaid диаграммы (если применимо)
- [ ] Содержит code examples
- [ ] Указано "Для кого" в начале
- [ ] Проверен на опечатки

---

## 📞 Support

**Вопросы по документации**:
- Создать issue с тегом `documentation`
- Описать, что непонятно и где

**Предложения по улучшению**:
- Pull request с изменениями в .md файлы
- Issue с предложением структуры

---

## 📅 Changelog

### 2025-12-01 - Initial Release
- Создана полная техническая документация
- 6 архитектурных документов
- 15+ Mermaid диаграмм
- Примеры кода и API запросов
- Индекс и навигация

---

**Последнее обновление**: 2025-12-01

**Версия документации**: 1.0.0

**Статус**: ✅ Complete
