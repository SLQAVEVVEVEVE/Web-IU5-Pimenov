# Quick Start - Быстрый старт с документацией

## 🎯 Начните здесь

Если вы впервые работаете с этим проектом, следуйте этому руководству:

---

## 1️⃣ Я новый разработчик (5 минут)

### Прочитайте в таком порядке:

1. **[README.md](README.md)** ← **НАЧНИТЕ ЗДЕСЬ**
   - Что это за проект
   - Технологический стек
   - Как запустить локально
   - **Время**: 3-5 минут

2. **[SYSTEM_OVERVIEW.md](architecture/SYSTEM_OVERVIEW.md)**
   - Большая картина системы
   - Визуальные диаграммы
   - **Время**: 5-7 минут

3. **[DOCKER_ARCHITECTURE.md](architecture/DOCKER_ARCHITECTURE.md)**
   - Как работает локальное окружение
   - Docker commands
   - **Время**: 3-5 минут

### Затем запустите проект:

```bash
# 1. Клонировать
git clone <repo-url>
cd exciting-greider

# 2. Создать .env
cp .env.example .env

# 3. Запустить Docker
docker-compose up

# 4. Миграции (в новом терминале)
docker-compose exec web bin/rails db:migrate

# 5. Открыть браузер
http://localhost:3000          # Web UI
http://localhost:3000/api-docs # Swagger
```

**Готово!** Теперь можете изучать код.

---

## 2️⃣ Я Backend разработчик (10 минут)

### Прочитайте эти документы:

1. **[ERD.md](architecture/ERD.md)** - Database schema
   - 4 таблицы: User, Beam, BeamDeflection, BeamDeflectionBeam
   - Связи и ограничения

2. **[STATE_MACHINE.md](architecture/STATE_MACHINE.md)** - Business logic
   - Жизненный цикл расчетов
   - draft → formed → completed/rejected

3. **[API_ARCHITECTURE.md](architecture/API_ARCHITECTURE.md)** - REST API
   - Все endpoints с примерами
   - Request/Response форматы

### Ключевые файлы в коде:

```
app/models/
├── user.rb                    # Пользователи + роли
├── beam.rb                    # Каталог балок
├── beam_deflection.rb         # Расчеты (state machine)
└── beam_deflection_beam.rb    # Join table

app/controllers/api/
├── auth_controller.rb         # JWT authentication
├── beams_controller.rb        # CRUD балок
└── beam_deflections_controller.rb  # Управление расчетами

app/services/
├── beam_deflection_state_machine.rb  # Workflow logic
└── jwt_blacklist.rb                  # Redis blacklist
```

---

## 3️⃣ Я Frontend/Mobile разработчик (5 минут)

### Прочитайте:

1. **[API_ARCHITECTURE.md](architecture/API_ARCHITECTURE.md)**
   - **Все endpoints** с curl примерами
   - JSON форматы
   - Error codes

2. **[AUTH_FLOW.md](architecture/AUTH_FLOW.md)**
   - JWT authentication
   - Как получить токен
   - Как использовать в headers

### Попробуйте Swagger UI:

```bash
# 1. Открыть
http://localhost:3000/api-docs

# 2. Sign Up для получения токена
POST /api/auth/sign_up

# 3. Authorize (кнопка вверху справа)
Bearer <ваш_токен>

# 4. Тестировать endpoints интерактивно
```

### Пример кода (JavaScript):

```javascript
// Sign In
const response = await fetch('http://localhost:3000/api/auth/sign_in', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});
const { token } = await response.json();

// Authenticated request
const profile = await fetch('http://localhost:3000/api/me', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

---

## 4️⃣ Я DevOps инженер (10 минут)

### Прочитайте:

1. **[DOCKER_ARCHITECTURE.md](architecture/DOCKER_ARCHITECTURE.md)**
   - 4 сервиса: web, db, redis, minio
   - Volumes, networking
   - Production considerations

2. **[README.md](README.md)** → секция "Production Deployment"
   - Checklist для production
   - Environment variables
   - Security настройки

### Ключевые файлы:

```
docker-compose.yml    # Оркестрация сервисов
Dockerfile            # Rails app image
.env                  # Environment variables
config/database.yml   # PostgreSQL config
config/initializers/redis.rb  # Redis config
```

### Quick commands:

```bash
# Start all
docker-compose up -d

# Logs
docker-compose logs -f web

# Exec into containers
docker-compose exec web bash
docker-compose exec db psql -U postgres

# Restart single service
docker-compose restart redis

# Stop all
docker-compose down
```

---

## 5️⃣ Я QA инженер (5 минут)

### Прочитайте:

1. **[STATE_MACHINE.md](architecture/STATE_MACHINE.md)**
   - Workflow для тестирования
   - Валидные/невалидные переходы

2. **[API_ARCHITECTURE.md](architecture/API_ARCHITECTURE.md)**
   - Все endpoints для тестирования
   - Expected error codes

### Тестовые сценарии:

**Сценарий 1: Happy Path (User)**
```
1. POST /api/auth/sign_up (создать пользователя)
2. POST /api/auth/sign_in (получить токен)
3. GET /api/beams (список балок)
4. POST /api/beams/1/add_to_draft (добавить в черновик)
5. PUT /api/beam_deflections/X (заполнить параметры)
6. PUT /api/beam_deflections/X/form (оформить)
7. Ожидать: status = "formed"
```

**Сценарий 2: Happy Path (Moderator)**
```
1. POST /api/auth/sign_in (moderator credentials)
2. GET /api/beam_deflections?status=formed
3. PUT /api/beam_deflections/X/complete
4. Ожидать: status = "completed"
```

**Сценарий 3: Negative (Permissions)**
```
1. Попытка create beam без moderator role
2. Ожидать: 403 Forbidden
```

### Run tests:

```bash
# All tests
docker-compose exec web bundle exec rspec

# Integration tests (API)
docker-compose exec web bundle exec rspec spec/integration/
```

---

## 6️⃣ Я архитектор / Tech Lead (15 минут)

### Прочитайте все в таком порядке:

1. **[SYSTEM_OVERVIEW.md](architecture/SYSTEM_OVERVIEW.md)** (7 мин)
   - C4 Context diagram
   - Компонентная архитектура
   - Technology stack
   - Scalability

2. **[README.md](README.md)** → "Архитектурные решения" (3 мин)
   - JWT + Redis blacklist (почему)
   - State Machine (почему)
   - MinIO vs Active Storage

3. **Пробегитесь по остальным** (5 мин)
   - ERD, STATE_MACHINE, API, AUTH, DOCKER

### Архитектурные паттерны:

- **Authentication**: JWT (stateless) + Redis blacklist (stateful logout)
- **Authorization**: Pundit policies + role-based
- **State Management**: Explicit state machine с валидацией
- **Storage**: S3-compatible MinIO (self-hosted)
- **Persistence**: PostgreSQL (primary data) + Redis (cache/blacklist)
- **API Style**: REST + JSON (Swagger docs)
- **Deployment**: Docker Compose (dev) → Kubernetes (prod)

---

## 📚 Полный индекс документации

### Основные документы

| Документ | Для кого | Время чтения |
|----------|----------|--------------|
| [README.md](README.md) | Все | 5 мин |
| [INDEX.md](INDEX.md) | Все (навигация) | 3 мин |
| [QUICKSTART.md](QUICKSTART.md) | Новички | 1 мин |

### Архитектурные документы

| Документ | Тема | Для кого | Время |
|----------|------|----------|-------|
| [SYSTEM_OVERVIEW.md](architecture/SYSTEM_OVERVIEW.md) | Общая архитектура | Архитекторы, Все | 7 мин |
| [ERD.md](architecture/ERD.md) | Database schema | Backend, DB Admin | 5 мин |
| [STATE_MACHINE.md](architecture/STATE_MACHINE.md) | Business workflow | Backend, QA | 7 мин |
| [API_ARCHITECTURE.md](architecture/API_ARCHITECTURE.md) | REST API | Frontend, Backend | 10 мин |
| [AUTH_FLOW.md](architecture/AUTH_FLOW.md) | Security | Backend, Security | 10 мин |
| [DOCKER_ARCHITECTURE.md](architecture/DOCKER_ARCHITECTURE.md) | Infrastructure | DevOps, Backend | 10 мин |

---

## 🔍 Поиск по темам

**Если вам нужно найти**:

| Что искать | Где найти |
|------------|-----------|
| Как запустить проект | README.md → "Быстрый старт" |
| Список API endpoints | API_ARCHITECTURE.md → "API Endpoints" |
| Database таблицы | ERD.md → "Описание сущностей" |
| JWT authentication | AUTH_FLOW.md → "JWT Token Service" |
| Docker commands | DOCKER_ARCHITECTURE.md → "Development Workflow" |
| State transitions | STATE_MACHINE.md → "Матрица переходов" |
| Troubleshooting | Любой документ → секция "Troubleshooting" |
| Production deployment | README.md → "Production Deployment" |

---

## ⚡ Быстрые ссылки

### Локальная разработка
- Web UI: http://localhost:3000
- Swagger: http://localhost:3000/api-docs
- MinIO Console: http://localhost:9001

### Commands
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

## 💡 Советы

1. **Начните с README.md** - это точка входа
2. **Используйте INDEX.md** - для быстрой навигации
3. **Swagger UI** - для интерактивного тестирования API
4. **Mermaid диаграммы** - рендерятся в GitHub/GitLab автоматически
5. **Code examples** - копируйте и адаптируйте под свои нужды

---

## 🤝 Нужна помощь?

- **Документация непонятна?** → Создайте issue с тегом `documentation`
- **Нашли ошибку?** → Pull request с исправлением
- **Есть вопрос?** → Спросите в team chat или создайте issue

---

**Приятной работы с проектом!** 🚀

**Последнее обновление**: 2025-12-01
