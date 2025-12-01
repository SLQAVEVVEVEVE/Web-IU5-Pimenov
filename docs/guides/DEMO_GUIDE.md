# Р СѓРєРѕРІРѕРґСЃС‚РІРѕ РїРѕ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё Beam Deflection API

## РџРѕРґРіРѕС‚РѕРІРєР°

### РЈС‡РµС‚РЅС‹Рµ РґР°РЅРЅС‹Рµ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

**РћР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ:**

- Email: `user@demo.com`
- Password: `password123`
- JWT Token: `eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4`

**РњРѕРґРµСЂР°С‚РѕСЂ:**

- Email: `moderator@demo.com`
- Password: `password123`
- JWT Token: `eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0`

### URL РїСЂРёР»РѕР¶РµРЅРёСЏ

- **Web UI**: [http://localhost:3000](http://localhost:3000)
- **Swagger UI**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- **API Base URL**: [http://localhost:3000/api](http://localhost:3000/api)

---

## РџРѕСЂСЏРґРѕРє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

### 1. РђСѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ С‡РµСЂРµР· Swagger (СЂРµР¶РёРј РёРЅРєРѕРіРЅРёС‚Рѕ)

1. РћС‚РєСЂРѕР№С‚Рµ Р±СЂР°СѓР·РµСЂ РІ **СЂРµР¶РёРјРµ РёРЅРєРѕРіРЅРёС‚Рѕ** (Ctrl+Shift+N РІ Chrome)
2. РџРµСЂРµР№РґРёС‚Рµ РЅР° [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
3. РќР°Р№РґРёС‚Рµ СЂР°Р·РґРµР» **Auth** Рё endpoint `POST /api/auth/sign_in`
4. РќР°Р¶РјРёС‚Рµ **"Try it out"**
5. Р’РІРµРґРёС‚Рµ РґР°РЅРЅС‹Рµ РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ:

   ```json
   {
     "email": "user@demo.com",
     "password": "password123"
   }
   ```

6. РќР°Р¶РјРёС‚Рµ **"Execute"**
7. Р’ РѕС‚РІРµС‚Рµ РїРѕР»СѓС‡РёС‚Рµ:
   - **HTTP 200 OK**
   - JWT С‚РѕРєРµРЅ РІ РїРѕР»Рµ `token`
   - Р”Р°РЅРЅС‹Рµ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ

**РЎРєСЂРёРЅС€РѕС‚ 1**: РЈСЃРїРµС€РЅР°СЏ Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ РІ Swagger

---

### 2. РџРѕР»СѓС‡РёС‚СЊ СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє РІ Swagger

1. РќР°Р№РґРёС‚Рµ endpoint `GET /api/beam_deflections`
2. РќР°Р¶РјРёС‚Рµ **"Authorize"** (РєРЅРѕРїРєР° СЃ Р·Р°РјРєРѕРј РІРІРµСЂС…Сѓ СЃС‚СЂР°РЅРёС†С‹)
3. Р’СЃС‚Р°РІСЊС‚Рµ JWT С‚РѕРєРµРЅ РёР· РїСЂРµРґС‹РґСѓС‰РµРіРѕ С€Р°РіР°
4. РќР°Р¶РјРёС‚Рµ **"Authorize"** Рё **"Close"**
5. Р’РµСЂРЅРёС‚РµСЃСЊ Рє `GET /api/beam_deflections`
6. РќР°Р¶РјРёС‚Рµ **"Try it out"** в†’ **"Execute"**
7. РџРѕР»СѓС‡РёС‚Рµ СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ (С‚РѕР»СЊРєРѕ СЃРІРѕРё, Р±РµР· РґСЂР°С„С‚РѕРІ)

**РЎРєСЂРёРЅС€РѕС‚ 2**: РЎРїРёСЃРѕРє Р·Р°СЏРІРѕРє РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РІ Swagger

---

### 3. РџРѕР»СѓС‡РёС‚СЊ Cookie/JWT РёР· Р±СЂР°СѓР·РµСЂР°

#### Р’Р°СЂРёР°РЅС‚ Рђ: Cookie РёР· Application (РґР»СЏ РІРµР±-РёРЅС‚РµСЂС„РµР№СЃР°)

1. РћС‚РєСЂРѕР№С‚Рµ DevTools (F12)
2. РџРµСЂРµР№РґРёС‚Рµ РЅР° РІРєР»Р°РґРєСѓ **Application** в†’ **Cookies** в†’ `http://localhost:3000`
3. РќР°Р№РґРёС‚Рµ cookie СЃ СЃРµСЃСЃРёРµР№
4. РЎРєРѕРїРёСЂСѓР№С‚Рµ Р·РЅР°С‡РµРЅРёРµ

#### Р’Р°СЂРёР°РЅС‚ Р‘: JWT РёР· РѕС‚РІРµС‚Р° Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёРё (СЂРµРєРѕРјРµРЅРґСѓРµС‚СЃСЏ)

1. Р’ Swagger UI РїРѕСЃР»Рµ Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёРё
2. РЎРєРѕРїРёСЂСѓР№С‚Рµ Р·РЅР°С‡РµРЅРёРµ РїРѕР»СЏ `token` РёР· Response body
3. РСЃРїРѕР»СЊР·СѓР№С‚Рµ СЌС‚РѕС‚ С‚РѕРєРµРЅ РґР»СЏ Р·Р°РіРѕР»РѕРІРєР° `Authorization: Bearer <token>`

**РЎРєСЂРёРЅС€РѕС‚ 3**: Cookie РІ Application РёР»Рё JWT РІ Response

---

### 4. Insomnia/Postman: GET СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє

#### 4.1. Р‘РµР· Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёРё (Р“РѕСЃС‚СЊ)

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:** (РїСѓСЃС‚Рѕ)

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 401 Unauthorized**

**РЎРєСЂРёРЅС€РѕС‚ 4**: 401 РґР»СЏ РіРѕСЃС‚СЏ

---

#### 4.2. РћР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ (С‚РѕР»СЊРєРѕ СЃРІРѕРё Р·Р°СЏРІРєРё)

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 200 OK**
- РЎРїРёСЃРѕРє Р·Р°СЏРІРѕРє, СЃРѕР·РґР°РЅРЅС‹С… С‚РѕР»СЊРєРѕ СЌС‚РёРј РїРѕР»СЊР·РѕРІР°С‚РµР»РµРј
- **РќР•** РІРєР»СЋС‡Р°РµС‚ РґСЂР°С„С‚С‹ (С‚РѕР»СЊРєРѕ formed/completed/rejected)

**РЎРєСЂРёРЅС€РѕС‚ 5**: РЎРїРёСЃРѕРє СЃРІРѕРёС… Р·Р°СЏРІРѕРє РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ

---

### 5. Insomnia/Postman: PUT Р·Р°РІРµСЂС€РµРЅРёРµ Р·Р°СЏРІРєРё

#### 5.1. РћР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ РїС‹С‚Р°РµС‚СЃСЏ Р·Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ

**Request:**

```http
PUT http://localhost:3000/api/beam_deflections/52/complete
```

> Р—Р°РјРµРЅРёС‚Рµ `52` РЅР° ID formed Р·Р°СЏРІРєРё РёР· РІР°С€РµР№ Р‘Р”

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 403 Forbidden**
- РЎРѕРѕР±С‰РµРЅРёРµ: "Moderator access required"

**РЎРєСЂРёРЅС€РѕС‚ 6**: 403 РґР»СЏ РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РїСЂРё РїРѕРїС‹С‚РєРµ Р·Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ

---

#### 5.2. РњРѕРґРµСЂР°С‚РѕСЂ СѓСЃРїРµС€РЅРѕ Р·Р°РІРµСЂС€Р°РµС‚ Р·Р°СЏРІРєСѓ

**Request:**

```http
PUT http://localhost:3000/api/beam_deflections/52/complete
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 200 OK**
- РћР±РЅРѕРІР»РµРЅРЅР°СЏ Р·Р°СЏРІРєР° СЃРѕ СЃС‚Р°С‚СѓСЃРѕРј `completed`
- Р—Р°РїРѕР»РЅРµРЅС‹ РїРѕР»СЏ:
  - `status: "completed"`
  - `completed_at: <timestamp>`
  - `moderator_login: "moderator@demo.com"`
  - `result_deflection_mm: <calculated_value>`
  - `within_norm: true/false`

**РЎРєСЂРёРЅС€РѕС‚ 7**: РЈСЃРїРµС€РЅРѕРµ Р·Р°РІРµСЂС€РµРЅРёРµ Р·Р°СЏРІРєРё РјРѕРґРµСЂР°С‚РѕСЂРѕРј

---

### 6. Insomnia/Postman: GET СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє РґР»СЏ РјРѕРґРµСЂР°С‚РѕСЂР°

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 200 OK**
- **Р’РЎР• Р·Р°СЏРІРєРё** РІ СЃРёСЃС‚РµРјРµ (РІРєР»СЋС‡Р°СЏ С‡СѓР¶РёРµ)
- **РќР•** РІРєР»СЋС‡Р°РµС‚ РґСЂР°С„С‚С‹ (С‚РѕР»СЊРєРѕ formed/completed/rejected)

**РЎРєСЂРёРЅС€РѕС‚ 8**: РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ Р·Р°СЏРІРєРё

---

#### 6.1. (Р”РћРџРћР›РќРРўР•Р›Р¬РќРћ) РњРѕРґРµСЂР°С‚РѕСЂ РїСЂРѕСЃРјР°С‚СЂРёРІР°РµС‚ РґСЂР°С„С‚С‹

**Request:**

```http
GET http://localhost:3000/api/beam_deflections?status=draft
```

**Headers:**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 200 OK**
- **Р’РЎР• РґСЂР°С„С‚С‹** РѕС‚ РІСЃРµС… РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№

**РЎРєСЂРёРЅС€РѕС‚ 9**: РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ РґСЂР°С„С‚С‹ (РЅРѕРІР°СЏ С„СѓРЅРєС†РёРѕРЅР°Р»СЊРЅРѕСЃС‚СЊ)

---

### 7. РЎРѕРґРµСЂР¶РёРјРѕРµ Redis С‡РµСЂРµР· CMD

#### 7.1. РџРѕРєР°Р·Р°С‚СЊ РІСЃРµ РєР»СЋС‡Рё РІ Redis

**РљРѕРјР°РЅРґР°:**

```bash
docker-compose exec redis redis-cli KEYS "*"
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

```redis
jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f
jwt:blacklist:ddd3d6539c4684d449b95310cf40acb8dcac6137e65686ac08156e7837092525
...
```

**РЎРєСЂРёРЅС€РѕС‚ 10**: РЎРїРёСЃРѕРє РєР»СЋС‡РµР№ РІ Redis

---

#### 7.2. РџРѕРєР°Р·Р°С‚СЊ СЃРѕРґРµСЂР¶РёРјРѕРµ blacklist С‚РѕРєРµРЅР°

**РљРѕРјР°РЅРґР°:**

```bash
docker-compose exec redis redis-cli GET "jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f"
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

```text
"blacklisted"
```

**РЎРєСЂРёРЅС€РѕС‚ 11**: РЎРѕРґРµСЂР¶РёРјРѕРµ blacklist РєР»СЋС‡Р°

---

#### 7.3. РџРѕРєР°Р·Р°С‚СЊ TTL (РІСЂРµРјСЏ Р¶РёР·РЅРё) РєР»СЋС‡Р°

**РљРѕРјР°РЅРґР°:**

```bash
docker-compose exec redis redis-cli TTL "jwt:blacklist:49b0fb38f813fbee246249414b5e357eb5686d9ace1eae12e1a5dbcc82010c8f"
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

```text
86398
```

(РІСЂРµРјСЏ РІ СЃРµРєСѓРЅРґР°С… РґРѕ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРіРѕ СѓРґР°Р»РµРЅРёСЏ)

**РЎРєСЂРёРЅС€РѕС‚ 12**: TTL РєР»СЋС‡Р° РІ Redis

---

#### 7.4. РЎРѕР·РґР°С‚СЊ РЅРѕРІС‹Р№ blacklist С‚РѕРєРµРЅ (Sign Out)

**Request РІ Insomnia/Postman:**

```http
POST http://localhost:3000/api/auth/sign_out
```

**Headers:**

```http
Authorization: Bearer <Р»СЋР±РѕР№_РІР°Р»РёРґРЅС‹Р№_С‚РѕРєРµРЅ>
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 204 No Content**

Р—Р°С‚РµРј РІС‹РїРѕР»РЅРёС‚СЊ:

```bash
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
```

Р”РѕР»Р¶РµРЅ РїРѕСЏРІРёС‚СЊСЃСЏ РЅРѕРІС‹Р№ РєР»СЋС‡.

**РЎРєСЂРёРЅС€РѕС‚ 13**: РќРѕРІС‹Р№ blacklist РєР»СЋС‡ РїРѕСЃР»Рµ sign_out

---

#### 7.5. РџРѕРїС‹С‚РєР° РёСЃРїРѕР»СЊР·РѕРІР°С‚СЊ blacklisted С‚РѕРєРµРЅ

**Request:**

```http
GET http://localhost:3000/api/beam_deflections
```

**Headers:**

```http
Authorization: Bearer <blacklisted_token>
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

- **HTTP 401 Unauthorized**
- РЎРѕРѕР±С‰РµРЅРёРµ: "Token has been revoked" (РёР»Рё Р°РЅР°Р»РѕРіРёС‡РЅРѕРµ)

**РЎРєСЂРёРЅС€РѕС‚ 14**: 401 РґР»СЏ blacklisted С‚РѕРєРµРЅР°

---

### 8. Redis: РџРѕРєР°Р·Р°С‚СЊ РёРЅС„РѕСЂРјР°С†РёСЋ Рѕ РїРѕР»СЊР·РѕРІР°С‚РµР»Рµ РёР· JWT

Р”Р»СЏ РёР·РІР»РµС‡РµРЅРёСЏ РёРЅС„РѕСЂРјР°С†РёРё Рѕ РїРѕР»СЊР·РѕРІР°С‚РµР»Рµ РёР· JWT С‚РѕРєРµРЅР°:

**РљРѕРјР°РЅРґР° (РґРµРєРѕРґРёСЂРѕРІР°РЅРёРµ JWT - Base64):**

```bash
echo "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4" | cut -d '.' -f 2 | base64 -d 2>/dev/null
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

```json
{"user_id":39,"exp":1764529550}
```

Р—Р°С‚РµРј РЅР°Р№С‚Рё РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ:

```bash
docker-compose exec web bin/rails runner "puts User.find(39).to_json"
```

**РћР¶РёРґР°РµРјС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚:**

```json
{"id":39,"email":"user@demo.com","moderator":false,...}
```

**РЎРєСЂРёРЅС€РѕС‚ 15**: РРЅС„РѕСЂРјР°С†РёСЏ Рѕ РїРѕР»СЊР·РѕРІР°С‚РµР»Рµ РёР· JWT

---

## Р”РѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РєРѕРјР°РЅРґС‹ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

### РџСЂРѕРІРµСЂРёС‚СЊ СЃС‚Р°С‚РёСЃС‚РёРєСѓ Redis

```bash
docker-compose exec redis redis-cli INFO stats
```

### РћС‡РёСЃС‚РёС‚СЊ РІСЃРµ blacklist РєР»СЋС‡Рё (РґР»СЏ РїРѕРІС‚РѕСЂРЅРѕР№ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё)

```bash
docker-compose exec redis redis-cli DEL $(docker-compose exec redis redis-cli KEYS "jwt:blacklist:*")
```

### РџРѕР»СѓС‡РёС‚СЊ РѕР±С‰СѓСЋ СЃС‚Р°С‚РёСЃС‚РёРєСѓ РїРѕ Р·Р°СЏРІРєР°Рј

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

## РЎРІРѕРґРєР° СЃРєСЂРёРЅС€РѕС‚РѕРІ РґР»СЏ РўР— 2025

1. вњ… РЈСЃРїРµС€РЅР°СЏ Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ РІ Swagger
2. вњ… РЎРїРёСЃРѕРє Р·Р°СЏРІРѕРє РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РІ Swagger
3. вњ… Cookie/JWT РІ Р±СЂР°СѓР·РµСЂРµ
4. вњ… 401 Unauthorized РґР»СЏ РіРѕСЃС‚СЏ
5. вњ… РЎРїРёСЃРѕРє СЃРІРѕРёС… Р·Р°СЏРІРѕРє РѕР±С‹С‡РЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ
6. вњ… 403 Forbidden РґР»СЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ (РїРѕРїС‹С‚РєР° Р·Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ)
7. вњ… РЈСЃРїРµС€РЅРѕРµ Р·Р°РІРµСЂС€РµРЅРёРµ Р·Р°СЏРІРєРё РјРѕРґРµСЂР°С‚РѕСЂРѕРј (200 OK)
8. вњ… РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ Р·Р°СЏРІРєРё
9. вњ… **РќРћР’РћР•**: РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ РґСЂР°С„С‚С‹ (СЃ РїР°СЂР°РјРµС‚СЂРѕРј ?status=draft)
10. вњ… РЎРїРёСЃРѕРє РєР»СЋС‡РµР№ РІ Redis
11. вњ… РЎРѕРґРµСЂР¶РёРјРѕРµ blacklist РєР»СЋС‡Р°
12. вњ… TTL РєР»СЋС‡Р° РІ Redis
13. вњ… РќРѕРІС‹Р№ blacklist РїРѕСЃР»Рµ sign_out
14. вњ… 401 РґР»СЏ blacklisted С‚РѕРєРµРЅР°
15. вњ… РРЅС„РѕСЂРјР°С†РёСЏ Рѕ РїРѕР»СЊР·РѕРІР°С‚РµР»Рµ РёР· JWT

---

## РџСЂРёРјРµС‡Р°РЅРёСЏ

- Р’СЃРµ С‚РѕРєРµРЅС‹ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹ 24 С‡Р°СЃР°
- Redis Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё СѓРґР°Р»СЏРµС‚ blacklist РєР»СЋС‡Рё РїРѕСЃР»Рµ РёСЃС‚РµС‡РµРЅРёСЏ СЃСЂРѕРєР° РґРµР№СЃС‚РІРёСЏ С‚РѕРєРµРЅР°
- Р”Р»СЏ РїРѕРІС‚РѕСЂРЅРѕР№ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё Р·Р°РїСѓСЃС‚РёС‚Рµ: `docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb`

