# Руководство по демонстрации Beam Deflection API

## Подготовка

### Учетные данные для демонстрации

**Обычный пользователь:**

- Email: `user@demo.com`
- Password: `password123`
- JWT Token: `eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4`

**Модератор:**

- Email: `moderator@demo.com`
- Password: `password123`
- JWT Token: `eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0`

### URL приложения

- **Web UI**: [http://localhost:3000](http://localhost:3000)
- **Swagger UI**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- **API Base URL**: [http://localhost:3000/api](http://localhost:3000/api)

---

## Порядок демонстрации

### 1. Аутентификация через Swagger (режим инкогнито)

1. Откройте браузер в **режиме инкогнито** (Ctrl+Shift+N в Chrome)
2. Перейдите на [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
3. Найдите раздел **Auth** и endpoint `POST /api/auth/sign_in`
4. Нажмите **"Try it out"**
5. Введите данные обычного пользователя:

   ```json
   {
     "email": "user@demo.com",
     "password": "password123"
   }
   ```

6. Нажмите **"Execute"**
7. В ответе получите:
   - **HTTP 200 OK**
   - JWT токен в поле `token`
   - Данные пользователя

**Скриншот 1**: Успешная аутентификация в Swagger

---

### 2. Получить список заявок в Swagger

1. Найдите endpoint `GET /api/beam_deflections`
2. Нажмите **"Authorize"** (кнопка с замком вверху страницы)
3. Вставьте JWT токен из предыдущего шага
4. Нажмите **"Authorize"** и **"Close"**
5. Вернитесь к `GET /api/beam_deflections`
6. Нажмите **"Try it out"** → **"Execute"**
7. Получите список заявок пользователя (только свои, без драфтов)

**Скриншот 2**: Список заявок обычного пользователя в Swagger

---

### 3. Получить Cookie/JWT из браузера

#### Вариант А: Cookie из Application (для веб-интерфейса)

1. Откройте DevTools (F12)
2. Перейдите на вкладку **Application** → **Cookies** → `http://localhost:3000`
3. Найдите cookie с сессией
4. Скопируйте значение

#### Вариант Б: JWT из ответа аутентификации (рекомендуется)

1. В Swagger UI после аутентификации
2. Скопируйте значение поля `token` из Response body
3. Используйте этот токен для заголовка `Authorization: Bearer <token>`

**Скриншот 3**: Cookie в Application или JWT в Response

---

### 4. Insomnia/Postman: GET список заявок

#### 4.1. Без аутентификации (Гость)

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:** (пусто)

**Ожидаемый результат:**

- **HTTP 401 Unauthorized**

**Скриншот 4**: 401 для гостя

---

#### 4.2. Обычный пользователь (только свои заявки)

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

**Ожидаемый результат:**

- **HTTP 200 OK**
- Список заявок, созданных только этим пользователем
- **НЕ** включает драфты (только formed/completed/rejected)

**Скриншот 5**: Список своих заявок обычного пользователя

---

### 5. Insomnia/Postman: PUT завершение заявки

#### 5.1. Обычный пользователь пытается завершить заявку

**Request:**

```http
PUT http://localhost:3000/api/beam_deflections/52/complete
```

> Замените `52` на ID formed заявки из вашей БД

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

**Ожидаемый результат:**

- **HTTP 403 Forbidden**
- Сообщение: "Moderator access required"

**Скриншот 6**: 403 для обычного пользователя при попытке завершить заявку

---

#### 5.2. Модератор успешно завершает заявку

**Request:**

```http
PUT http://localhost:3000/api/beam_deflections/52/complete
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**Ожидаемый результат:**

- **HTTP 200 OK**
- Обновленная заявка со статусом `completed`
- Заполнены поля:
  - `status: "completed"`
  - `completed_at: <timestamp>`
  - `moderator_login: "moderator@demo.com"`
  - `result_deflection_mm: <calculated_value>`
  - `within_norm: true/false`

**Скриншот 7**: Успешное завершение заявки модератором

---

### 6. Insomnia/Postman: GET список заявок для модератора

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**Ожидаемый результат:**

- **HTTP 200 OK**
- **ВСЕ заявки** в системе (включая чужие)
- **НЕ** включает драфты (только formed/completed/rejected)

**Скриншот 8**: Модератор видит все заявки

---

#### 6.1. (ДОПОЛНИТЕЛЬНО) Модератор просматривает драфты

**Request:**

```http
GET http://localhost:3000/api/beam_deflections?status=draft
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**Ожидаемый результат:**

- **HTTP 200 OK**
- **ВСЕ драфты** от всех пользователей

**Скриншот 9**: Модератор видит все драфты (новая функциональность)

---

### 7. Содержимое Redis через CMD

#### 7.1. Показать все ключи в Redis

**Команда:**

```bash
docker-compose exec redis redis-cli KEYS "*"
```

**Ожидаемый результат:**

```redis
jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f
jwt:blacklist:ddd3d6539c4684d449b95310cf40acb8dcac6137e65686ac08156e7837092525
...
```

**Скриншот 10**: Список ключей в Redis

---

#### 7.2. Показать содержимое blacklist токена

**Команда:**

```bash
docker-compose exec redis redis-cli GET "jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f"
```

**Ожидаемый результат:**

```text
"blacklisted"
```

**Скриншот 11**: Содержимое blacklist ключа

---

#### 7.3. Показать TTL (время жизни) ключа

**Команда:**

```bash
docker-compose exec redis redis-cli TTL "jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f"
```

**Ожидаемый результат:**

```text
86398
```

(время в секундах до автоматического удаления)

**Скриншот 12**: TTL ключа в Redis

---

#### 7.4. Создать новый blacklist токен (Sign Out)

**Request в Insomnia/Postman:**

```http
POST http://localhost:3000/api/auth/sign_out
```

**Headers:**

```http
Authorization: Bearer <любой_валидный_токен>
```

**Ожидаемый результат:**

- **HTTP 204 No Content**

Затем выполнить:

```bash
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
```

Должен появиться новый ключ.

**Скриншот 13**: Новый blacklist ключ после sign_out

---

#### 7.5. Попытка использовать blacklisted токен

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer <blacklisted_token>
```

**Ожидаемый результат:**

- **HTTP 401 Unauthorized**
- Сообщение: "Token has been revoked" (или аналогичное)

**Скриншот 14**: 401 для blacklisted токена

---

### 8. Redis: Показать информацию о пользователе из JWT

Для извлечения информации о пользователе из JWT токена:

**Команда (декодирование JWT - Base64):**

```bash
echo "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4" | cut -d '.' -f 2 | base64 -d 2>/dev/null
```

**Ожидаемый результат:**

```json
{"user_id":39,"exp":1764529550}
```

Затем найти пользователя:

```bash
docker-compose exec web bin/rails runner "puts User.find(39).to_json"
```

**Ожидаемый результат:**

```json
{"id":39,"email":"user@demo.com","moderator":false,...}
```

**Скриншот 15**: Информация о пользователе из JWT

---

## Дополнительные команды для демонстрации

### Проверить статистику Redis

```bash
docker-compose exec redis redis-cli INFO stats
```

### Очистить все blacklist ключи (для повторной демонстрации)

```bash
docker-compose exec redis redis-cli DEL $(docker-compose exec redis redis-cli KEYS "jwt:blacklist:*")
```

### Получить общую статистику по заявкам

```bash
docker-compose exec web bin/rails runner "
puts 'Total beam deflections: #{BeamDeflection.count}'
puts '  Draft: #{BeamDeflection.draft.count}'
puts '  Formed: #{BeamDeflection.formed.count}'
puts '  Completed: #{BeamDeflection.completed.count}'
puts '  Rejected: #{BeamDeflection.rejected.count}'
"
```

---

## Сводка скриншотов для ТЗ 2025

1. ✅ Успешная аутентификация в Swagger
2. ✅ Список заявок обычного пользователя в Swagger
3. ✅ Cookie/JWT в браузере
4. ✅ 401 Unauthorized для гостя
5. ✅ Список своих заявок обычного пользователя
6. ✅ 403 Forbidden для пользователя (попытка завершить заявку)
7. ✅ Успешное завершение заявки модератором (200 OK)
8. ✅ Модератор видит все заявки
9. ✅ **НОВОЕ**: Модератор видит все драфты (с параметром ?status=draft)
10. ✅ Список ключей в Redis
11. ✅ Содержимое blacklist ключа
12. ✅ TTL ключа в Redis
13. ✅ Новый blacklist после sign_out
14. ✅ 401 для blacklisted токена
15. ✅ Информация о пользователе из JWT

---

## Примечания

- Все токены действительны 24 часа
- Redis автоматически удаляет blacklist ключи после истечения срока действия токена
- Для повторной демонстрации запустите: `docker-compose exec web bin/rails runner prepare_demo.rb`
