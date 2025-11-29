# Быстрые команды для демонстрации

## Учетные данные

```
User: user@demo.com / password123
Moderator: moderator@demo.com / password123
```

## JWT Токены

```bash
# User Token
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4

# Moderator Token
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

## Insomnia/Postman Requests

### 1. Sign In (Обычный пользователь)
```
POST http://localhost:3000/api/auth/sign_in
Content-Type: application/json

{
  "email": "user@demo.com",
  "password": "password123"
}
```

### 2. Sign In (Модератор)
```
POST http://localhost:3000/api/auth/sign_in
Content-Type: application/json

{
  "email": "moderator@demo.com",
  "password": "password123"
}
```

### 3. GET заявки (без токена) → 401
```
GET http://localhost:3000/api/beam_deflections
```

### 4. GET заявки (обычный пользователь) → только свои
```
GET http://localhost:3000/api/beam_deflections
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### 5. Complete заявки (обычный пользователь) → 403
```
PUT http://localhost:3000/api/beam_deflections/52/complete
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### 6. Complete заявки (модератор) → 200 OK
```
PUT http://localhost:3000/api/beam_deflections/52/complete
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 7. GET заявки (модератор) → все заявки
```
GET http://localhost:3000/api/beam_deflections
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 8. GET драфты (модератор) → все драфты ✨ НОВОЕ
```
GET http://localhost:3000/api/beam_deflections?status=draft
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 9. Sign Out (добавить токен в blacklist)
```
POST http://localhost:3000/api/auth/sign_out
Authorization: Bearer <токен_для_блокировки>
```

## Redis Commands

```bash
# Показать все ключи
docker-compose exec redis redis-cli KEYS "*"

# Показать blacklist ключи
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"

# Получить значение ключа
docker-compose exec redis redis-cli GET "jwt:blacklist:<hash>"

# Показать TTL ключа
docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"

# Подсчитать количество blacklist ключей
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*" | wc -l

# Redis статистика
docker-compose exec redis redis-cli INFO stats

# Очистить все blacklist ключи
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*" | xargs docker-compose exec redis redis-cli DEL
```

## Rails Commands

```bash
# Подготовить demo данные
docker-compose exec web bin/rails runner prepare_demo.rb

# Статистика по заявкам
docker-compose exec web bin/rails runner "
puts 'Draft: #{BeamDeflection.draft.count}'
puts 'Formed: #{BeamDeflection.formed.count}'
puts 'Completed: #{BeamDeflection.completed.count}'
"

# Найти пользователя по ID
docker-compose exec web bin/rails runner "puts User.find(39).inspect"

# Декодировать JWT (показать payload)
docker-compose exec web bin/rails runner "
token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4'
puts JwtToken.decode(token).inspect
"
```

## URLs

- **Swagger UI**: http://localhost:3000/api-docs
- **Web UI**: http://localhost:3000
- **API**: http://localhost:3000/api

## Проверка ID заявок для демонстрации

```bash
# Найти formed заявку для completion
docker-compose exec web bin/rails runner "
bd = BeamDeflection.formed.first
puts \"Use ID: #{bd.id}\" if bd
"
```

## Сброс демо-данных

```bash
# Удалить все beam deflections
docker-compose exec web bin/rails runner "BeamDeflection.destroy_all"

# Пересоздать демо данные
docker-compose exec web bin/rails runner prepare_demo.rb
```
