# Project Snapshot - Beam Deflection API

**Р”Р°С‚Р°**: 2025-01-29
**Р’РµСЂСЃРёСЏ**: РџРѕСЃР»Рµ СЂРµР°Р»РёР·Р°С†РёРё С„СѓРЅРєС†РёРё РїСЂРѕСЃРјРѕС‚СЂР° РґСЂР°С„С‚РѕРІ РјРѕРґРµСЂР°С‚РѕСЂРѕРј

---

## рџЋЇ РўРµРєСѓС‰РµРµ СЃРѕСЃС‚РѕСЏРЅРёРµ РїСЂРѕРµРєС‚Р°

### Р РµР°Р»РёР·РѕРІР°РЅРЅР°СЏ С„СѓРЅРєС†РёРѕРЅР°Р»СЊРЅРѕСЃС‚СЊ

вњ… **JWT Authentication СЃ Redis Blacklist**
- РўРѕРєРµРЅС‹ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹ 24 С‡Р°СЃР°
- Sign out РґРѕР±Р°РІР»СЏРµС‚ С‚РѕРєРµРЅС‹ РІ blacklist
- Redis Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё СѓРґР°Р»СЏРµС‚ СѓСЃС‚Р°СЂРµРІС€РёРµ С‚РѕРєРµРЅС‹ (TTL)

вњ… **Role-based Authorization**
- РћР±С‹С‡РЅС‹Рµ РїРѕР»СЊР·РѕРІР°С‚РµР»Рё: СЃРѕР·РґР°СЋС‚ Рё СѓРїСЂР°РІР»СЏСЋС‚ СЃРІРѕРёРјРё Р·Р°СЏРІРєР°РјРё
- РњРѕРґРµСЂР°С‚РѕСЂС‹: Р·Р°РІРµСЂС€Р°СЋС‚/РѕС‚РєР»РѕРЅСЏСЋС‚ Р·Р°СЏРІРєРё, РІРёРґСЏС‚ РІСЃРµ Р·Р°СЏРІРєРё

вњ… **Beam Deflections (Р—Р°СЏРІРєРё РЅР° СЂР°СЃС‡РµС‚ РїСЂРѕРіРёР±Р° Р±Р°Р»РѕРє)**
- РЎС‚Р°С‚СѓСЃС‹: draft в†’ formed в†’ completed/rejected/deleted
- State machine СЃ РїСЂРѕРІРµСЂРєРѕР№ РїСЂР°РІ РґРѕСЃС‚СѓРїР°
- Р Р°СЃС‡РµС‚ РїСЂРѕРіРёР±Р° СЃ СѓС‡РµС‚РѕРј РјР°С‚РµСЂРёР°Р»РѕРІ Рё РЅР°РіСЂСѓР·РѕРє

вњ… **РќРѕРІР°СЏ С„СѓРЅРєС†РёСЏ (2025-01-29): РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ РґСЂР°С„С‚С‹**
- Endpoint: `GET /api/beam_deflections?status=draft`
- РўРѕР»СЊРєРѕ РґР»СЏ РјРѕРґРµСЂР°С‚РѕСЂРѕРІ
- Р’РѕР·РІСЂР°С‰Р°РµС‚ РґСЂР°С„С‚С‹ РѕС‚ РІСЃРµС… РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№
- РСЃРїРѕР»СЊР·СѓРµС‚ РёСЃРїСЂР°РІР»РµРЅРЅСѓСЋ РїР°РіРёРЅР°С†РёСЋ

---

## рџ“‚ РЎС‚СЂСѓРєС‚СѓСЂР° РїСЂРѕРµРєС‚Р°

### РљР»СЋС‡РµРІС‹Рµ С„Р°Р№Р»С‹

**РњРѕРґРµР»Рё:**
- `app/models/beam.rb` - Р‘Р°Р»РєРё (РјР°С‚РµСЂРёР°Р»С‹, СЃРІРѕР№СЃС‚РІР°)
- `app/models/beam_deflection.rb` - Р—Р°СЏРІРєРё РЅР° СЂР°СЃС‡РµС‚
- `app/models/beam_deflection_beam.rb` - Many-to-many СЃ РґРѕРї. РїРѕР»СЏРјРё
- `app/models/user.rb` - РџРѕР»СЊР·РѕРІР°С‚РµР»Рё СЃ JWT auth

**РљРѕРЅС‚СЂРѕР»Р»РµСЂС‹:**
- `app/controllers/api/base_controller.rb` - JWT auth, Current.user
- `app/controllers/api/beam_deflections_controller.rb` - CRUD Р·Р°СЏРІРѕРє
- `app/controllers/api/beams_controller.rb` - CRUD Р±Р°Р»РѕРє
- `app/controllers/api/auth_controller.rb` - Sign in/out/up

**РЎРµСЂРІРёСЃС‹:**
- `app/lib/jwt_token.rb` - Encoding/decoding JWT
- `app/services/jwt_blacklist.rb` - Redis blacklist
- `app/services/beam_deflection_state_machine.rb` - State transitions

**РљРѕРЅС„РёРіСѓСЂР°С†РёСЏ:**
- `config/initializers/redis.rb` - Redis connection
- `config/application.rb` - Hosts РґР»СЏ С‚РµСЃС‚РѕРІ
- `config/environments/test.rb` - Test environment

---

## рџ”§ РСЃРїСЂР°РІР»РµРЅРЅС‹Рµ РїСЂРѕР±Р»РµРјС‹

### 1. Pagination Bug (CRITICAL)
**РџСЂРѕР±Р»РµРјР°:** `per_page` РІРѕР·РІСЂР°С‰Р°Р» 1 СЌР»РµРјРµРЅС‚ РІРјРµСЃС‚Рѕ 20 РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ

**Р‘С‹Р»Рѕ:**
```ruby
per = [[params[:per_page].to_i, 1].max, 100].min
per = 20 if per.zero?
```

**РЎС‚Р°Р»Рѕ:**
```ruby
per = params[:per_page].to_i
per = 20 if per.zero? || per < 0
per = [per, 100].min
```

**Р¤Р°Р№Р»:** `app/controllers/api/beam_deflections_controller.rb:39-41`

### 2. Test Users Creation
**РџСЂРѕР±Р»РµРјР°:** Integration tests СЃРѕР·РґР°РІР°Р»Рё РґСѓР±Р»РёРєР°С‚С‹ РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№

**РСЃРїСЂР°РІР»РµРЅРёРµ:** Р—Р°РјРµРЅРµРЅРѕ `User.create!` РЅР° `User.find_or_create_by!`

**Р¤Р°Р№Р»С‹:**
- `spec/integration/beam_deflections_spec.rb`
- `spec/integration/beams_spec.rb`

### 3. Test Environment Hosts
**РџСЂРѕР±Р»РµРјР°:** www.example.com Р±Р»РѕРєРёСЂРѕРІР°Р»СЃСЏ РІ С‚РµСЃС‚Р°С…

**РСЃРїСЂР°РІР»РµРЅРёРµ:** Р”РѕР±Р°РІР»РµРЅРѕ РІ `config/application.rb:43`
```ruby
config.hosts << "www.example.com" if Rails.env.test?
```

---

## рџ“Љ Р‘Р°Р·Р° РґР°РЅРЅС‹С…

### РўРµСЃС‚РѕРІС‹Рµ РїРѕР»СЊР·РѕРІР°С‚РµР»Рё
```
user@demo.com / password123 (ID: 39, moderator: false)
moderator@demo.com / password123 (ID: 40, moderator: true)
```

### JWT РўРѕРєРµРЅС‹ (РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹ РґРѕ 2025-12-29)
```
User: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
Moderator: eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### РўРµСЃС‚РѕРІС‹Рµ Р·Р°СЏРІРєРё
```
Draft: ID=51 (user@demo.com)
Formed: ID=52 (user@demo.com) в†ђ РСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё completion
Completed: ID=25
```

### Р‘Р°Р»РєРё
```
Р’СЃРµРіРѕ: 9
Wooden Beam 50x150 (ID: 39)
Steel Beam 100x200 (ID: 40)
```

---

## рџЊђ Endpoints

### Authentication
- `POST /api/auth/sign_in` - Login (РІРѕР·РІСЂР°С‰Р°РµС‚ JWT)
- `POST /api/auth/sign_up` - Registration
- `POST /api/auth/sign_out` - Logout (blacklist С‚РѕРєРµРЅ)

### User
- `GET /api/me` - Current user profile

### Beams
- `GET /api/beams` - List all beams (public)
- `POST /api/beams` - Create beam (moderator only)
- `PUT /api/beams/:id` - Update beam (moderator only)
- `DELETE /api/beams/:id` - Delete beam (moderator only)

### Beam Deflections
- `GET /api/beam_deflections` - List requests
  - User: С‚РѕР»СЊРєРѕ СЃРІРѕРё (Р±РµР· РґСЂР°С„С‚РѕРІ)
  - Moderator: РІСЃРµ (Р±РµР· РґСЂР°С„С‚РѕРІ)
- `GET /api/beam_deflections?status=draft` вњЁ **NEW** - All drafts (moderator only)
- `GET /api/beam_deflections/:id` - Get request details
- `PUT /api/beam_deflections/:id` - Update request (draft/formed only)
- `PUT /api/beam_deflections/:id/form` - Submit draft в†’ formed
- `PUT /api/beam_deflections/:id/complete` - Complete request (moderator only)
- `PUT /api/beam_deflections/:id/reject` - Reject request (moderator only)
- `DELETE /api/beam_deflections/:id` - Soft delete (creator only)

### Beam Deflection Items
- `PUT /api/beam_deflections/:id/items/update_item` - Add/update beam in request
- `DELETE /api/beam_deflections/:id/items/remove_item` - Remove beam from request

### Utility
- `GET /api/beam_deflections/cart_badge` - Draft items count

---

## рџ”Ќ Redis Keys

### JWT Blacklist
```
Pattern: jwt:blacklist:<sha256_hash>
Value: "blacklisted"
TTL: РґРѕ РёСЃС‚РµС‡РµРЅРёСЏ С‚РѕРєРµРЅР°
```

**РљРѕРјР°РЅРґС‹:**
```bash
# Р’СЃРµ blacklist РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"

# РљРѕР»РёС‡РµСЃС‚РІРѕ
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*" | wc -l

# TTL РєР»СЋС‡Р°
docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"
```

---

## рџ“Ѓ Р”РµРјРѕРЅСЃС‚СЂР°С†РёРѕРЅРЅС‹Рµ С„Р°Р№Р»С‹

РЎРѕР·РґР°РЅРЅС‹Рµ С„Р°Р№Р»С‹ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё РїСЂРѕРµРєС‚Р°:

1. **README_DEMO.md** - Р“Р»Р°РІРЅС‹Р№ С„Р°Р№Р» СЃ РѕР±Р·РѕСЂРѕРј
2. **DEMO_READY.md** - Р§РµРєР»РёСЃС‚ РґР»СЏ Р±С‹СЃС‚СЂРѕРіРѕ СЃС‚Р°СЂС‚Р°
3. **DEMO_GUIDE.md** - РџРѕРґСЂРѕР±РЅРѕРµ СЂСѓРєРѕРІРѕРґСЃС‚РІРѕ РЅР° 15 С€Р°РіРѕРІ
4. **QUICK_DEMO_COMMANDS.md** - РЁРїР°СЂРіР°Р»РєР° СЃ РєРѕРјР°РЅРґР°РјРё
5. **Insomnia_Collection.json** - Р“РѕС‚РѕРІР°СЏ РєРѕР»Р»РµРєС†РёСЏ Р·Р°РїСЂРѕСЃРѕРІ
6. **utilities/scripts/prepare_demo.rb** - РЎРєСЂРёРїС‚ РїРѕРґРіРѕС‚РѕРІРєРё РґР°РЅРЅС‹С…
7. **utilities/scripts/verify_demo.rb** - РџСЂРѕРІРµСЂРєР° РіРѕС‚РѕРІРЅРѕСЃС‚Рё Рє РґРµРјРѕ

---

## рџљЂ Docker Services

### Running Services
```
web - Rails app (port 3000)
db - PostgreSQL 15 (port 5432)
redis - Redis 7 (port 6379)
minio - MinIO (ports 9000-9001)
```

### Commands
```bash
# Р—Р°РїСѓСЃС‚РёС‚СЊ РІСЃРµ СЃРµСЂРІРёСЃС‹
docker-compose up

# РћСЃС‚Р°РЅРѕРІРёС‚СЊ
docker-compose down

# РџРµСЂРµР·Р°РїСѓСЃС‚РёС‚СЊ web
docker-compose restart web

# Р›РѕРіРё
docker-compose logs -f web

# Rails console
docker-compose exec web bin/rails console

# РњРёРіСЂР°С†РёРё
docker-compose exec web bin/rails db:migrate

# РџРѕРґРіРѕС‚РѕРІРёС‚СЊ РґРµРјРѕ РґР°РЅРЅС‹Рµ
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb

# РџСЂРѕРІРµСЂРёС‚СЊ РіРѕС‚РѕРІРЅРѕСЃС‚СЊ
docker-compose exec web bin/rails runner utilities/scripts/verify_demo.rb
```

---

## рџ§Є Testing

### Integration Tests
```bash
# Р’СЃРµ С‚РµСЃС‚С‹
docker-compose exec web bundle exec rspec

# РўРѕР»СЊРєРѕ beams
docker-compose exec web bundle exec rspec spec/integration/beams_spec.rb

# РўРѕР»СЊРєРѕ beam_deflections
docker-compose exec web bundle exec rspec spec/integration/beam_deflections_spec.rb
```

### Known Issues
- Integration tests РёРјРµСЋС‚ РїСЂРѕР±Р»РµРјСѓ СЃ host authorization (РЅРµ РєСЂРёС‚РёС‡РЅРѕ)
- Р¤СѓРЅРєС†РёРѕРЅР°Р»СЊРЅРѕСЃС‚СЊ СЂР°Р±РѕС‚Р°РµС‚ РєРѕСЂСЂРµРєС‚РЅРѕ РїСЂРё СЂСѓС‡РЅРѕРј С‚РµСЃС‚РёСЂРѕРІР°РЅРёРё

---

## рџ“ќ Git Status

### Modified Files
```
M app/controllers/api/beam_deflections_controller.rb (pagination fix)
M spec/integration/beam_deflections_spec.rb (user creation fix)
M spec/integration/beams_spec.rb (user creation fix)
M config/environments/test.rb (hosts config)
```

### New Files (Demo)
```
A DEMO_GUIDE.md
A DEMO_READY.md
A QUICK_DEMO_COMMANDS.md
A README_DEMO.md
A Insomnia_Collection.json
A utilities/scripts/prepare_demo.rb
A utilities/scripts/verify_demo.rb
A PROJECT_SNAPSHOT.md
```

---

## рџ”„ Р’РѕСЃСЃС‚Р°РЅРѕРІР»РµРЅРёРµ СЃРѕСЃС‚РѕСЏРЅРёСЏ

### Р•СЃР»Рё РЅСѓР¶РЅРѕ РІРѕСЃСЃС‚Р°РЅРѕРІРёС‚СЊ РґРµРјРѕ-РґР°РЅРЅС‹Рµ
```bash
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb
```

### Р•СЃР»Рё РЅСѓР¶РЅРѕ РѕС‡РёСЃС‚РёС‚СЊ Redis blacklist
```bash
docker-compose exec redis redis-cli FLUSHDB
```

### Р•СЃР»Рё РЅСѓР¶РЅРѕ РїРµСЂРµСЃРѕР·РґР°С‚СЊ Р±Р°Р·Сѓ
```bash
docker-compose exec web bin/rails db:drop db:create db:migrate
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb
```

---

## рџ“€ РЎС‚Р°С‚РёСЃС‚РёРєР° РїСЂРѕРµРєС‚Р°

**РњРѕРґРµР»Рё:** 4 РѕСЃРЅРѕРІРЅС‹Рµ (User, Beam, BeamDeflection, BeamDeflectionBeam)
**РљРѕРЅС‚СЂРѕР»Р»РµСЂС‹:** 6 API РєРѕРЅС‚СЂРѕР»Р»РµСЂРѕРІ
**Endpoints:** ~15 API endpoints
**Tests:** Integration tests СЃ Swagger documentation
**Database:** PostgreSQL + Redis
**Authentication:** JWT with blacklist

---

## вњ… Р“РѕС‚РѕРІРЅРѕСЃС‚СЊ Рє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

- вњ… Р’СЃРµ СЃРµСЂРІРёСЃС‹ Р·Р°РїСѓС‰РµРЅС‹
- вњ… Р”РµРјРѕ-РїРѕР»СЊР·РѕРІР°С‚РµР»Рё СЃРѕР·РґР°РЅС‹
- вњ… РўРµСЃС‚РѕРІС‹Рµ Р·Р°СЏРІРєРё РіРѕС‚РѕРІС‹
- вњ… JWT С‚РѕРєРµРЅС‹ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹
- вњ… Redis blacklist СЂР°Р±РѕС‚Р°РµС‚
- вњ… Р’СЃРµ endpoints РїСЂРѕС‚РµСЃС‚РёСЂРѕРІР°РЅС‹
- вњ… Р”РѕРєСѓРјРµРЅС‚Р°С†РёСЏ РіРѕС‚РѕРІР°
- вњ… Insomnia collection СЃРѕР·РґР°РЅР°

---

## рџЋЇ РЎР»РµРґСѓСЋС‰РёРµ С€Р°РіРё (РґР»СЏ Р±СѓРґСѓС‰РёС… СЃРµСЃСЃРёР№)

1. РСЃРїСЂР°РІРёС‚СЊ integration tests (hosts issue)
2. РћР±РЅРѕРІРёС‚СЊ seeds.rb (Р·Р°РјРµРЅРёС‚СЊ Service РЅР° Beam)
3. Р”РѕР±Р°РІРёС‚СЊ API tests РґР»СЏ РЅРѕРІРѕР№ С„СѓРЅРєС†РёРё РґСЂР°С„С‚РѕРІ
4. РћР±РЅРѕРІРёС‚СЊ Swagger documentation РґР»СЏ ?status=draft
5. Р Р°СЃСЃРјРѕС‚СЂРµС‚СЊ РґРѕР±Р°РІР»РµРЅРёРµ С„РёР»СЊС‚СЂРѕРІ РїРѕ РґР°С‚Р°Рј РґР»СЏ РґСЂР°С„С‚РѕРІ

---

**Snapshot СЃРѕР·РґР°РЅ**: 2025-01-29
**РџРѕСЃР»РµРґРЅРµРµ РёР·РјРµРЅРµРЅРёРµ**: Р”РѕР±Р°РІР»РµРЅР° С„СѓРЅРєС†РёСЏ РїСЂРѕСЃРјРѕС‚СЂР° РІСЃРµС… РґСЂР°С„С‚РѕРІ РјРѕРґРµСЂР°С‚РѕСЂРѕРј
**Р“РѕС‚РѕРІ Рє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё**: вњ… Р”Рђ

