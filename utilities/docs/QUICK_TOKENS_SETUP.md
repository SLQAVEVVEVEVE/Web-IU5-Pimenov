# вљЎ Р‘С‹СЃС‚СЂР°СЏ РЅР°СЃС‚СЂРѕР№РєР° С‚РѕРєРµРЅРѕРІ РІ Insomnia

## рџЋЇ Р“РґРµ РѕР±РЅРѕРІР»СЏС‚СЊ РїРµСЂРµРјРµРЅРЅС‹Рµ РѕРєСЂСѓР¶РµРЅРёСЏ

### РћС‚РєСЂС‹С‚СЊ Environment Manager:
```
Insomnia (РІРІРµСЂС…Сѓ) в†’ Р’С‹РїР°РґР°СЋС‰РёР№ СЃРїРёСЃРѕРє в†’ Manage Environments (вљ™пёЏ)
```

---

## рџ“‹ Р§РµРє-Р»РёСЃС‚: Р§С‚Рѕ Рё РєРѕРіРґР° РєРѕРїРёСЂРѕРІР°С‚СЊ

| Р—Р°РїСЂРѕСЃ | Р§С‚Рѕ РєРѕРїРёСЂРѕРІР°С‚СЊ РёР· РѕС‚РІРµС‚Р° | РљСѓРґР° РІСЃС‚Р°РІРёС‚СЊ | РћР±СЏР·Р°С‚РµР»СЊРЅРѕ? |
|--------|--------------------------|---------------|--------------|
| **#17 Sign In (User)** | `token` | в†’ `user_token` | вњ… Р”Рђ |
| **#18 Sign In (Moderator)** | `token` | в†’ `moderator_token` | вњ… Р”Рђ |
| **#5 Create Beam** | `id` | в†’ `new_beam_id` | вљ пёЏ Р–РµР»Р°С‚РµР»СЊРЅРѕ |
| **#9 Cart Badge** | `beam_deflection_id` | в†’ `draft_id` | вљ пёЏ Р–РµР»Р°С‚РµР»СЊРЅРѕ |
| **#16 Sign Up** | `token` | в†’ `new_user_token` | в­• РћРїС†РёРѕРЅР°Р»СЊРЅРѕ |

---

## рџљЂ Р‘С‹СЃС‚СЂС‹Р№ СЃС‚Р°СЂС‚ (3 РјРёРЅСѓС‚С‹)

### 1пёЏвѓЈ РРјРїРѕСЂС‚ (30 СЃРµРє)
```
Insomnia в†’ Import/Export в†’ Import Data в†’ From File
в†’ Р’С‹Р±СЂР°С‚СЊ: Insomnia_Collection_DEMO.json
```

### 2пёЏвѓЈ РџРѕР»СѓС‡РёС‚СЊ С‚РѕРєРµРЅС‹ (1 РјРёРЅ)
**Р—Р°РїСЂРѕСЃ #17:**
```
POST /api/auth/sign_in
Body: { "email": "user@demo.com", "password": "password123" }
в†’ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ token РёР· РѕС‚РІРµС‚Р°
```

**Р—Р°РїСЂРѕСЃ #18:**
```
POST /api/auth/sign_in
Body: { "email": "moderator@demo.com", "password": "password123" }
в†’ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ token РёР· РѕС‚РІРµС‚Р°
```

### 3пёЏвѓЈ РћР±РЅРѕРІРёС‚СЊ Environment (1.5 РјРёРЅ)
```
Manage Environments в†’ Base Environment
```

Р’СЃС‚Р°РІРёС‚СЊ С‚РѕРєРµРЅС‹:
```json
{
  "base_url": "http://localhost:3000",
  "user_token": "Р’РЎРўРђР’РРўР¬_РЎР®Р”Рђ_РўРћРљР•Рќ_РР—_Р—РђРџР РћРЎРђ_17",
  "moderator_token": "Р’РЎРўРђР’РРўР¬_РЎР®Р”Рђ_РўРћРљР•Рќ_РР—_Р—РђРџР РћРЎРђ_18",
  "new_beam_id": "",
  "draft_id": "",
  "formed_id": "52",
  "new_user_token": ""
}
```

РќР°Р¶Р°С‚СЊ **Done**.

### 4пёЏвѓЈ Р“РѕС‚РѕРІРѕ! вњ…
РўРµРїРµСЂСЊ РјРѕР¶РµС‚Рµ РІС‹РїРѕР»РЅСЏС‚СЊ Р·Р°РїСЂРѕСЃС‹ **01-21 РїРѕ РїРѕСЂСЏРґРєСѓ**.

---

## рџЋ¬ РџСЂРёРјРµСЂ РѕС‚РІРµС‚Р° СЃ С‚РѕРєРµРЅРѕРј

### Р’С‹РїРѕР»РЅРёР»Рё Р·Р°РїСЂРѕСЃ #17:
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

### РЎРєРѕРїРёСЂСѓР№С‚Рµ:

```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### Р’СЃС‚Р°РІСЊС‚Рµ РІ Environment:
```json
{
  "user_token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4"
}
```

---

## рџ’Ў Р“РѕС‚РѕРІС‹Рµ С‚РѕРєРµРЅС‹ (РµСЃР»Рё СѓР¶Рµ РµСЃС‚СЊ РґРµРјРѕ-РґР°РЅРЅС‹Рµ)

Р•СЃР»Рё РІС‹ Р·Р°РїСѓСЃРєР°Р»Рё `utilities/scripts/prepare_demo.rb`, РјРѕР¶РµС‚Рµ СЃСЂР°Р·Сѓ РёСЃРїРѕР»СЊР·РѕРІР°С‚СЊ СЌС‚Рё С‚РѕРєРµРЅС‹:

### РЎРєРѕРїРёСЂСѓР№С‚Рµ РІ Environment:
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

**вљ пёЏ Р’РђР–РќРћ:** Р­С‚Рё С‚РѕРєРµРЅС‹ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹ РґРѕ **2025-12-29**!

---

## рџ”§ РљР°Рє РёСЃРїРѕР»СЊР·РѕРІР°С‚СЊ РїРµСЂРµРјРµРЅРЅС‹Рµ

### Р’ Headers:
```
Authorization: Bearer {{ _.user_token }}
```
в†“ РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРё РїСЂРµРІСЂР°С‚РёС‚СЃСЏ РІ:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Р’ URL:
```
GET {{ _.base_url }}/api/beams/{{ _.new_beam_id }}
```
в†“ РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРё РїСЂРµРІСЂР°С‚РёС‚СЃСЏ РІ:
```
GET http://localhost:3000/api/beams/39
```

---

## вќ— Р§Р°СЃС‚С‹Рµ РѕС€РёР±РєРё

### РћС€РёР±РєР°: 401 Unauthorized
**РџСЂРёС‡РёРЅР°:** РќРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅС‹ С‚РѕРєРµРЅС‹

**Р РµС€РµРЅРёРµ:**
1. Р’С‹РїРѕР»РЅРёС‚Рµ Р·Р°РїСЂРѕСЃС‹ #17 Рё #18
2. РЎРєРѕРїРёСЂСѓР№С‚Рµ С‚РѕРєРµРЅС‹ РІ `user_token` Рё `moderator_token`

---

### РћС€РёР±РєР°: Variable not found "draft_id"
**РџСЂРёС‡РёРЅР°:** РќРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅ draft_id

**Р РµС€РµРЅРёРµ:**
1. Р’С‹РїРѕР»РЅРёС‚Рµ Р·Р°РїСЂРѕСЃС‹ #7, #8 (РґРѕР±Р°РІР»РµРЅРёРµ СѓСЃР»СѓРі РІ Р·Р°СЏРІРєСѓ)
2. Р’С‹РїРѕР»РЅРёС‚Рµ Р·Р°РїСЂРѕСЃ #9 (cart_badge)
3. РЎРєРѕРїРёСЂСѓР№С‚Рµ `beam_deflection_id` РІ `draft_id`

---

### РћС€РёР±РєР°: 404 Not Found РЅР° /api/beams/{{ _.new_beam_id }}
**РџСЂРёС‡РёРЅР°:** РџРµСЂРµРјРµРЅРЅР°СЏ `new_beam_id` РїСѓСЃС‚Р°СЏ

**Р РµС€РµРЅРёРµ:**
1. Р’С‹РїРѕР»РЅРёС‚Рµ Р·Р°РїСЂРѕСЃ #5 (Create Beam)
2. РЎРєРѕРїРёСЂСѓР№С‚Рµ `id` РёР· РѕС‚РІРµС‚Р° РІ `new_beam_id`

---

## рџ“ќ РљСЂР°С‚РєРёР№ РёС‚РѕРі

1. **РРјРїРѕСЂС‚РёСЂСѓР№С‚Рµ** `Insomnia_Collection_DEMO.json`
2. **Р’С‹РїРѕР»РЅРёС‚Рµ #17 Рё #18** в†’ РЎРєРѕРїРёСЂСѓР№С‚Рµ С‚РѕРєРµРЅС‹ РІ Environment
3. **Р’С‹РїРѕР»РЅСЏР№С‚Рµ РѕСЃС‚Р°Р»СЊРЅС‹Рµ Р·Р°РїСЂРѕСЃС‹** РїРѕ РїРѕСЂСЏРґРєСѓ (01-21)
4. **РџРѕ РЅРµРѕР±С…РѕРґРёРјРѕСЃС‚Рё** РѕР±РЅРѕРІР»СЏР№С‚Рµ `new_beam_id` Рё `draft_id`

**Р“РѕС‚РѕРІРѕ!** рџЋ‰

---

## рџ† РќСѓР¶РЅР° РїРѕРјРѕС‰СЊ?

РџРѕР»РЅР°СЏ РёРЅСЃС‚СЂСѓРєС†РёСЏ: **INSOMNIA_SETUP_GUIDE.md**

Р СѓРєРѕРІРѕРґСЃС‚РІРѕ РїРѕ С‚РµСЃС‚РёСЂРѕРІР°РЅРёСЋ: **DEMO_TESTING_GUIDE.md**

Insomnia РєРѕР»Р»РµРєС†РёСЏ: **Insomnia_Collection_DEMO.json**

