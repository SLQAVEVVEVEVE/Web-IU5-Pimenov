# ✅ Все готово для демонстрации!

## 📁 Созданные файлы

1. **DEMO_GUIDE.md** - Подробное руководство по демонстрации с описанием всех шагов
2. **QUICK_DEMO_COMMANDS.md** - Быстрая шпаргалка с командами и токенами
3. **Insomnia_Collection.json** - Коллекция запросов для импорта в Insomnia/Postman
4. **prepare_demo.rb** - Скрипт для подготовки демо-данных

## 🎯 Подготовленные данные

### Пользователи
- ✅ **user@demo.com** / password123 (обычный пользователь)
- ✅ **moderator@demo.com** / password123 (модератор)

### Заявки (Beam Deflections)
- ✅ Draft (ID: 51) - для демонстрации просмотра драфтов модератором
- ✅ Formed (ID: 52) - **ИСПОЛЬЗУЙТЕ ЭТО ID** для демонстрации завершения
- ✅ Completed (ID: 53) - пример завершенной заявки

### Балки (Beams)
- ✅ Wooden Beam 50x150 (ID: 39)
- ✅ Steel Beam 100x200 (ID: 40)

## 🚀 Быстрый старт

### 1. Импортировать коллекцию в Insomnia/Postman
```
Файл: Insomnia_Collection.json
```

### 2. Открыть Swagger UI
```
http://localhost:3000/api-docs
```

### 3. Проверить Redis
```bash
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
```

## 📋 Порядок демонстрации (чеклист)

- [ ] **Шаг 1**: Аутентификация через Swagger (инкогнито)
  - URL: http://localhost:3000/api-docs
  - Endpoint: POST /api/auth/sign_in
  - Email: user@demo.com
  - Password: password123

- [ ] **Шаг 2**: GET список заявок в Swagger
  - Authorize с полученным токеном
  - GET /api/beam_deflections

- [ ] **Шаг 3**: Скопировать JWT токен
  - Из Response body поле "token"

- [ ] **Шаг 4**: Insomnia - GET без токена → 401
  - Request #3 в коллекции

- [ ] **Шаг 5**: Insomnia - GET с user токеном → только свои
  - Request #4 в коллекции
  - Должно вернуть только заявки user@demo.com

- [ ] **Шаг 6**: Insomnia - PUT complete с user токеном → 403
  - Request #5 в коллекции
  - ID: 52

- [ ] **Шаг 7**: Insomnia - Sign In как модератор
  - Request #2 в коллекции
  - Email: moderator@demo.com

- [ ] **Шаг 8**: Insomnia - PUT complete с moderator токеном → 200
  - Request #6 в коллекции
  - ID: 52
  - Проверить: status=completed, moderator_login заполнен

- [ ] **Шаг 9**: Insomnia - GET все заявки модератором
  - Request #7 в коллекции
  - Должно вернуть ВСЕ заявки

- [ ] **Шаг 10**: ✨ **НОВОЕ** - GET все драфты модератором
  - Request #8 в коллекции
  - GET /api/beam_deflections?status=draft
  - Должно вернуть драфты от всех пользователей

- [ ] **Шаг 11**: CMD - Показать Redis blacklist
  ```bash
  docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
  ```

- [ ] **Шаг 12**: Insomnia - Sign Out (создать blacklist)
  - Request #9 (заменить токен на актуальный)

- [ ] **Шаг 13**: CMD - Проверить новый blacklist ключ
  ```bash
  docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
  ```

- [ ] **Шаг 14**: Insomnia - GET с blacklisted токеном → 401
  - Request #10 (использовать blacklisted токен)

- [ ] **Шаг 15**: CMD - Показать TTL ключа
  ```bash
  docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"
  ```

## 🎬 Готовые JWT токены (действительны 24 часа)

### User Token
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### Moderator Token
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

## ⚠️ Важные ID для демонстрации

- **Formed Request ID для completion**: `52`
- **User ID**: `39` (user@demo.com)
- **Moderator ID**: `40` (moderator@demo.com)

## 🔄 Пересоздать демо-данные

Если нужно пересоздать данные:
```bash
docker-compose exec web bin/rails runner prepare_demo.rb
```

## 📸 Скриншоты для ТЗ 2025

Нужно сделать скриншоты:

1. ✅ Успешная аутентификация в Swagger
2. ✅ Список заявок в Swagger
3. ✅ Cookie/JWT в DevTools
4. ✅ 401 для гостя (Insomnia)
5. ✅ Список своих заявок пользователя (Insomnia)
6. ✅ 403 при попытке завершить заявку пользователем (Insomnia)
7. ✅ 200 при завершении заявки модератором (Insomnia)
8. ✅ Модератор видит все заявки (Insomnia)
9. ✨ **НОВОЕ**: Модератор видит все драфты с ?status=draft (Insomnia)
10. ✅ Список blacklist ключей в Redis (CMD)
11. ✅ Содержимое blacklist ключа (CMD)
12. ✅ TTL ключа (CMD)
13. ✅ Новый blacklist после sign_out (CMD)
14. ✅ 401 для blacklisted токена (Insomnia)
15. ✅ Декодированный JWT с user_id (CMD или онлайн)

## 🔍 Полезные команды для демонстрации

### Redis
```bash
# Все ключи
docker-compose exec redis redis-cli KEYS "*"

# Blacklist ключи
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"

# Значение ключа
docker-compose exec redis redis-cli GET "jwt:blacklist:<hash>"

# TTL ключа
docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"

# Количество ключей
docker-compose exec redis redis-cli DBSIZE
```

### Rails
```bash
# Статистика заявок
docker-compose exec web bin/rails runner "
puts 'Draft: ' + BeamDeflection.draft.count.to_s
puts 'Formed: ' + BeamDeflection.formed.count.to_s
puts 'Completed: ' + BeamDeflection.completed.count.to_s
"

# Найти пользователя
docker-compose exec web bin/rails runner "puts User.find(39).to_json"
```

## 🎯 Что нового реализовано

✨ **Модератор может просматривать все драфты**
- Endpoint: `GET /api/beam_deflections?status=draft`
- Только для модераторов
- Возвращает драфты от всех пользователей
- Использует исправленную пагинацию

## ✅ Все работает!

- ✅ Приложение запущено: http://localhost:3000
- ✅ Swagger UI доступен: http://localhost:3000/api-docs
- ✅ Redis работает и доступен
- ✅ Демо-данные созданы
- ✅ JWT токены действительны
- ✅ Все endpoints протестированы

---

**Готово к демонстрации! 🎉**
