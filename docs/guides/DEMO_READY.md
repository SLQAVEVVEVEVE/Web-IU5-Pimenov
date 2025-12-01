# вњ… Р’СЃРµ РіРѕС‚РѕРІРѕ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё!

## рџ“Ѓ РЎРѕР·РґР°РЅРЅС‹Рµ С„Р°Р№Р»С‹

1. **DEMO_GUIDE.md** - РџРѕРґСЂРѕР±РЅРѕРµ СЂСѓРєРѕРІРѕРґСЃС‚РІРѕ РїРѕ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё СЃ РѕРїРёСЃР°РЅРёРµРј РІСЃРµС… С€Р°РіРѕРІ
2. **QUICK_DEMO_COMMANDS.md** - Р‘С‹СЃС‚СЂР°СЏ С€РїР°СЂРіР°Р»РєР° СЃ РєРѕРјР°РЅРґР°РјРё Рё С‚РѕРєРµРЅР°РјРё
3. **Insomnia_Collection.json** - РљРѕР»Р»РµРєС†РёСЏ Р·Р°РїСЂРѕСЃРѕРІ РґР»СЏ РёРјРїРѕСЂС‚Р° РІ Insomnia/Postman
4. **utilities/scripts/prepare_demo.rb** - РЎРєСЂРёРїС‚ РґР»СЏ РїРѕРґРіРѕС‚РѕРІРєРё РґРµРјРѕ-РґР°РЅРЅС‹С…

## рџЋЇ РџРѕРґРіРѕС‚РѕРІР»РµРЅРЅС‹Рµ РґР°РЅРЅС‹Рµ

### РџРѕР»СЊР·РѕРІР°С‚РµР»Рё
- вњ… **user@demo.com** / password123 (РѕР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ)
- вњ… **moderator@demo.com** / password123 (РјРѕРґРµСЂР°С‚РѕСЂ)

### Р—Р°СЏРІРєРё (Beam Deflections)
- вњ… Draft (ID: 51) - РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё РїСЂРѕСЃРјРѕС‚СЂР° РґСЂР°С„С‚РѕРІ РјРѕРґРµСЂР°С‚РѕСЂРѕРј
- вњ… Formed (ID: 52) - **РРЎРџРћР›Р¬Р—РЈР™РўР• Р­РўРћ ID** РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё Р·Р°РІРµСЂС€РµРЅРёСЏ
- вњ… Completed (ID: 53) - РїСЂРёРјРµСЂ Р·Р°РІРµСЂС€РµРЅРЅРѕР№ Р·Р°СЏРІРєРё

### Р‘Р°Р»РєРё (Beams)
- вњ… Wooden Beam 50x150 (ID: 39)
- вњ… Steel Beam 100x200 (ID: 40)

## рџљЂ Р‘С‹СЃС‚СЂС‹Р№ СЃС‚Р°СЂС‚

### 1. РРјРїРѕСЂС‚РёСЂРѕРІР°С‚СЊ РєРѕР»Р»РµРєС†РёСЋ РІ Insomnia/Postman
```
Р¤Р°Р№Р»: Insomnia_Collection.json
```

### 2. РћС‚РєСЂС‹С‚СЊ Swagger UI
```
http://localhost:3000/api-docs
```

### 3. РџСЂРѕРІРµСЂРёС‚СЊ Redis
```bash
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
```

## рџ“‹ РџРѕСЂСЏРґРѕРє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё (С‡РµРєР»РёСЃС‚)

- [ ] **РЁР°Рі 1**: РђСѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ С‡РµСЂРµР· Swagger (РёРЅРєРѕРіРЅРёС‚Рѕ)
  - URL: http://localhost:3000/api-docs
  - Endpoint: POST /api/auth/sign_in
  - Email: user@demo.com
  - Password: password123

- [ ] **РЁР°Рі 2**: GET СЃРїРёСЃРѕРє Р·Р°СЏРІРѕРє РІ Swagger
  - Authorize СЃ РїРѕР»СѓС‡РµРЅРЅС‹Рј С‚РѕРєРµРЅРѕРј
  - GET /api/beam_deflections

- [ ] **РЁР°Рі 3**: РЎРєРѕРїРёСЂРѕРІР°С‚СЊ JWT С‚РѕРєРµРЅ
  - РР· Response body РїРѕР»Рµ "token"

- [ ] **РЁР°Рі 4**: Insomnia - GET Р±РµР· С‚РѕРєРµРЅР° в†’ 401
  - Request #3 РІ РєРѕР»Р»РµРєС†РёРё

- [ ] **РЁР°Рі 5**: Insomnia - GET СЃ user С‚РѕРєРµРЅРѕРј в†’ С‚РѕР»СЊРєРѕ СЃРІРѕРё
  - Request #4 РІ РєРѕР»Р»РµРєС†РёРё
  - Р”РѕР»Р¶РЅРѕ РІРµСЂРЅСѓС‚СЊ С‚РѕР»СЊРєРѕ Р·Р°СЏРІРєРё user@demo.com

- [ ] **РЁР°Рі 6**: Insomnia - PUT complete СЃ user С‚РѕРєРµРЅРѕРј в†’ 403
  - Request #5 РІ РєРѕР»Р»РµРєС†РёРё
  - ID: 52

- [ ] **РЁР°Рі 7**: Insomnia - Sign In РєР°Рє РјРѕРґРµСЂР°С‚РѕСЂ
  - Request #2 РІ РєРѕР»Р»РµРєС†РёРё
  - Email: moderator@demo.com

- [ ] **РЁР°Рі 8**: Insomnia - PUT complete СЃ moderator С‚РѕРєРµРЅРѕРј в†’ 200
  - Request #6 РІ РєРѕР»Р»РµРєС†РёРё
  - ID: 52
  - РџСЂРѕРІРµСЂРёС‚СЊ: status=completed, moderator_login Р·Р°РїРѕР»РЅРµРЅ

- [ ] **РЁР°Рі 9**: Insomnia - GET РІСЃРµ Р·Р°СЏРІРєРё РјРѕРґРµСЂР°С‚РѕСЂРѕРј
  - Request #7 РІ РєРѕР»Р»РµРєС†РёРё
  - Р”РѕР»Р¶РЅРѕ РІРµСЂРЅСѓС‚СЊ Р’РЎР• Р·Р°СЏРІРєРё

- [ ] **РЁР°Рі 10**: вњЁ **РќРћР’РћР•** - GET РІСЃРµ РґСЂР°С„С‚С‹ РјРѕРґРµСЂР°С‚РѕСЂРѕРј
  - Request #8 РІ РєРѕР»Р»РµРєС†РёРё
  - GET /api/beam_deflections?status=draft
  - Р”РѕР»Р¶РЅРѕ РІРµСЂРЅСѓС‚СЊ РґСЂР°С„С‚С‹ РѕС‚ РІСЃРµС… РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№

- [ ] **РЁР°Рі 11**: CMD - РџРѕРєР°Р·Р°С‚СЊ Redis blacklist
  ```bash
  docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
  ```

- [ ] **РЁР°Рі 12**: Insomnia - Sign Out (СЃРѕР·РґР°С‚СЊ blacklist)
  - Request #9 (Р·Р°РјРµРЅРёС‚СЊ С‚РѕРєРµРЅ РЅР° Р°РєС‚СѓР°Р»СЊРЅС‹Р№)

- [ ] **РЁР°Рі 13**: CMD - РџСЂРѕРІРµСЂРёС‚СЊ РЅРѕРІС‹Р№ blacklist РєР»СЋС‡
  ```bash
  docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"
  ```

- [ ] **РЁР°Рі 14**: Insomnia - GET СЃ blacklisted С‚РѕРєРµРЅРѕРј в†’ 401
  - Request #10 (РёСЃРїРѕР»СЊР·РѕРІР°С‚СЊ blacklisted С‚РѕРєРµРЅ)

- [ ] **РЁР°Рі 15**: CMD - РџРѕРєР°Р·Р°С‚СЊ TTL РєР»СЋС‡Р°
  ```bash
  docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"
  ```

## рџЋ¬ Р“РѕС‚РѕРІС‹Рµ JWT С‚РѕРєРµРЅС‹ (РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹ 24 С‡Р°СЃР°)

### User Token
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### Moderator Token
```
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

## вљ пёЏ Р’Р°Р¶РЅС‹Рµ ID РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

- **Formed Request ID РґР»СЏ completion**: `52`
- **User ID**: `39` (user@demo.com)
- **Moderator ID**: `40` (moderator@demo.com)

## рџ”„ РџРµСЂРµСЃРѕР·РґР°С‚СЊ РґРµРјРѕ-РґР°РЅРЅС‹Рµ

Р•СЃР»Рё РЅСѓР¶РЅРѕ РїРµСЂРµСЃРѕР·РґР°С‚СЊ РґР°РЅРЅС‹Рµ:
```bash
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb
```

## рџ“ё РЎРєСЂРёРЅС€РѕС‚С‹ РґР»СЏ РўР— 2025

РќСѓР¶РЅРѕ СЃРґРµР»Р°С‚СЊ СЃРєСЂРёРЅС€РѕС‚С‹:

1. вњ… РЈСЃРїРµС€РЅР°СЏ Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ РІ Swagger
2. вњ… РЎРїРёСЃРѕРє Р·Р°СЏРІРѕРє РІ Swagger
3. вњ… Cookie/JWT РІ DevTools
4. вњ… 401 РґР»СЏ РіРѕСЃС‚СЏ (Insomnia)
5. вњ… РЎРїРёСЃРѕРє СЃРІРѕРёС… Р·Р°СЏРІРѕРє РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ (Insomnia)
6. вњ… 403 РїСЂРё РїРѕРїС‹С‚РєРµ Р·Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ РїРѕР»СЊР·РѕРІР°С‚РµР»РµРј (Insomnia)
7. вњ… 200 РїСЂРё Р·Р°РІРµСЂС€РµРЅРёРё Р·Р°СЏРІРєРё РјРѕРґРµСЂР°С‚РѕСЂРѕРј (Insomnia)
8. вњ… РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ Р·Р°СЏРІРєРё (Insomnia)
9. вњЁ **РќРћР’РћР•**: РњРѕРґРµСЂР°С‚РѕСЂ РІРёРґРёС‚ РІСЃРµ РґСЂР°С„С‚С‹ СЃ ?status=draft (Insomnia)
10. вњ… РЎРїРёСЃРѕРє blacklist РєР»СЋС‡РµР№ РІ Redis (CMD)
11. вњ… РЎРѕРґРµСЂР¶РёРјРѕРµ blacklist РєР»СЋС‡Р° (CMD)
12. вњ… TTL РєР»СЋС‡Р° (CMD)
13. вњ… РќРѕРІС‹Р№ blacklist РїРѕСЃР»Рµ sign_out (CMD)
14. вњ… 401 РґР»СЏ blacklisted С‚РѕРєРµРЅР° (Insomnia)
15. вњ… Р”РµРєРѕРґРёСЂРѕРІР°РЅРЅС‹Р№ JWT СЃ user_id (CMD РёР»Рё РѕРЅР»Р°Р№РЅ)

## рџ”Ќ РџРѕР»РµР·РЅС‹Рµ РєРѕРјР°РЅРґС‹ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

### Redis
```bash
# Р’СЃРµ РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "*"

# Blacklist РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"

# Р—РЅР°С‡РµРЅРёРµ РєР»СЋС‡Р°
docker-compose exec redis redis-cli GET "jwt:blacklist:<hash>"

# TTL РєР»СЋС‡Р°
docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"

# РљРѕР»РёС‡РµСЃС‚РІРѕ РєР»СЋС‡РµР№
docker-compose exec redis redis-cli DBSIZE
```

### Rails
```bash
# РЎС‚Р°С‚РёСЃС‚РёРєР° Р·Р°СЏРІРѕРє
docker-compose exec web bin/rails runner "
puts 'Draft: ' + BeamDeflection.draft.count.to_s
puts 'Formed: ' + BeamDeflection.formed.count.to_s
puts 'Completed: ' + BeamDeflection.completed.count.to_s
"

# РќР°Р№С‚Рё РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ
docker-compose exec web bin/rails runner "puts User.find(39).to_json"
```

## рџЋЇ Р§С‚Рѕ РЅРѕРІРѕРіРѕ СЂРµР°Р»РёР·РѕРІР°РЅРѕ

вњЁ **РњРѕРґРµСЂР°С‚РѕСЂ РјРѕР¶РµС‚ РїСЂРѕСЃРјР°С‚СЂРёРІР°С‚СЊ РІСЃРµ РґСЂР°С„С‚С‹**
- Endpoint: `GET /api/beam_deflections?status=draft`
- РўРѕР»СЊРєРѕ РґР»СЏ РјРѕРґРµСЂР°С‚РѕСЂРѕРІ
- Р’РѕР·РІСЂР°С‰Р°РµС‚ РґСЂР°С„С‚С‹ РѕС‚ РІСЃРµС… РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№
- РСЃРїРѕР»СЊР·СѓРµС‚ РёСЃРїСЂР°РІР»РµРЅРЅСѓСЋ РїР°РіРёРЅР°С†РёСЋ

## вњ… Р’СЃРµ СЂР°Р±РѕС‚Р°РµС‚!

- вњ… РџСЂРёР»РѕР¶РµРЅРёРµ Р·Р°РїСѓС‰РµРЅРѕ: http://localhost:3000
- вњ… Swagger UI РґРѕСЃС‚СѓРїРµРЅ: http://localhost:3000/api-docs
- вњ… Redis СЂР°Р±РѕС‚Р°РµС‚ Рё РґРѕСЃС‚СѓРїРµРЅ
- вњ… Р”РµРјРѕ-РґР°РЅРЅС‹Рµ СЃРѕР·РґР°РЅС‹
- вњ… JWT С‚РѕРєРµРЅС‹ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹
- вњ… Р’СЃРµ endpoints РїСЂРѕС‚РµСЃС‚РёСЂРѕРІР°РЅС‹

---

**Р“РѕС‚РѕРІРѕ Рє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё! рџЋ‰**

