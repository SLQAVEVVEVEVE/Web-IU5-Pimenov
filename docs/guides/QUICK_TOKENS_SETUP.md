# ⚡ Быстрая настройка токенов в Insomnia

## 🎯 Где обновлять переменные окружения

### Открыть Environment Manager:
```
Insomnia (вверху) → Выпадающий список → Manage Environments (⚙️)
```

---

## 📋 Чек-лист: Что и когда копировать

| Запрос | Что копировать из ответа | Куда вставить | Обязательно? |
|--------|--------------------------|---------------|--------------|
| **#17 Sign In (User)** | `token` | → `user_token` | ✅ ДА |
| **#18 Sign In (Moderator)** | `token` | → `moderator_token` | ✅ ДА |
| **#5 Create Beam** | `id` | → `new_beam_id` | ⚠️ Желательно |
| **#9 Cart Badge** | `beam_deflection_id` | → `draft_id` | ⚠️ Желательно |
| **#16 Sign Up** | `token` | → `new_user_token` | ⭕ Опционально |

---

## 🚀 Быстрый старт (3 минуты)

### 1️⃣ Импорт (30 сек)
```
Insomnia → Import/Export → Import Data → From File
→ Выбрать: Insomnia_Collection_DEMO.json
```

### 2️⃣ Получить токены (1 мин)
**Запрос #17:**
```
POST /api/auth/sign_in
Body: { "email": "user@demo.com", "password": "password123" }
→ Скопировать token из ответа
```

**Запрос #18:**
```
POST /api/auth/sign_in
Body: { "email": "moderator@demo.com", "password": "password123" }
→ Скопировать token из ответа
```

### 3️⃣ Обновить Environment (1.5 мин)
```
Manage Environments → Base Environment
```

Вставить токены:
```json
{
  "base_url": "http://localhost:3000",
  "user_token": "ВСТАВИТЬ_СЮДА_ТОКЕН_ИЗ_ЗАПРОСА_17",
  "moderator_token": "ВСТАВИТЬ_СЮДА_ТОКЕН_ИЗ_ЗАПРОСА_18",
  "new_beam_id": "",
  "draft_id": "",
  "formed_id": "52",
  "new_user_token": ""
}
```

Нажать **Done**.

### 4️⃣ Готово! ✅
Теперь можете выполнять запросы **01-21 по порядку**.

---

## 🎬 Пример ответа с токеном

### Выполнили запрос #17:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4",
  "user": {
    "id": 39,
    "email": "user@demo.com",
    "moderator": false
  }
}
```

### Скопируйте:
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### Вставьте в Environment:
```json
{
  "user_token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4"
}
```

---

## 💡 Готовые токены (если уже есть демо-данные)

Если вы запускали `prepare_demo.rb`, можете сразу использовать эти токены:

### Скопируйте в Environment:
```json
{
  "base_url": "http://localhost:3000",
  "user_token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4",
  "moderator_token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0",
  "new_beam_id": "39",
  "draft_id": "51",
  "formed_id": "52"
}
```

**⚠️ ВАЖНО:** Эти токены действительны до **2025-12-29**!

---

## 🔧 Как использовать переменные

### В Headers:
```
Authorization: Bearer {{ _.user_token }}
```
↓ Автоматически превратится в:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### В URL:
```
GET {{ _.base_url }}/api/beams/{{ _.new_beam_id }}
```
↓ Автоматически превратится в:
```
GET http://localhost:3000/api/beams/39
```

---

## ❗ Частые ошибки

### Ошибка: 401 Unauthorized
**Причина:** Не установлены токены

**Решение:**
1. Выполните запросы #17 и #18
2. Скопируйте токены в `user_token` и `moderator_token`

---

### Ошибка: Variable not found "draft_id"
**Причина:** Не установлен draft_id

**Решение:**
1. Выполните запросы #7, #8 (добавление услуг в заявку)
2. Выполните запрос #9 (cart_badge)
3. Скопируйте `beam_deflection_id` в `draft_id`

---

### Ошибка: 404 Not Found на /api/beams/{{ _.new_beam_id }}
**Причина:** Переменная `new_beam_id` пустая

**Решение:**
1. Выполните запрос #5 (Create Beam)
2. Скопируйте `id` из ответа в `new_beam_id`

---

## 📝 Краткий итог

1. **Импортируйте** `Insomnia_Collection_DEMO.json`
2. **Выполните #17 и #18** → Скопируйте токены в Environment
3. **Выполняйте остальные запросы** по порядку (01-21)
4. **По необходимости** обновляйте `new_beam_id` и `draft_id`

**Готово!** 🎉

---

## 🆘 Нужна помощь?

Полная инструкция: **INSOMNIA_SETUP_GUIDE.md**

Руководство по тестированию: **DEMO_TESTING_GUIDE.md**

Insomnia коллекция: **Insomnia_Collection_DEMO.json**
