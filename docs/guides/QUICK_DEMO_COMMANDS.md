# Р‘С‹СЃС‚СЂС‹Рµ РєРѕРјР°РЅРґС‹ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

## РЈС‡РµС‚РЅС‹Рµ РґР°РЅРЅС‹Рµ

```
User: user@demo.com / password123
Moderator: moderator@demo.com / password123
```

## JWT РўРѕРєРµРЅС‹

```bash
# User Token
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4

# Moderator Token
eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

## Insomnia/Postman Requests

### 1. Sign In (РћР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ)
```
POST http://localhost:3000/api/auth/sign_in
Content-Type: application/json

{
  "email": "user@demo.com",
  "password": "password123"
}
```

### 2. Sign In (РњРѕРґРµСЂР°С‚РѕСЂ)
```
POST http://localhost:3000/api/auth/sign_in
Content-Type: application/json

{
  "email": "moderator@demo.com",
  "password": "password123"
}
```

### 3. GET Р·Р°СЏРІРєРё (Р±РµР· С‚РѕРєРµРЅР°) в†’ 401
```
GET http://localhost:3000/api/beam_deflections
```

### 4. GET Р·Р°СЏРІРєРё (РѕР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ) в†’ С‚РѕР»СЊРєРѕ СЃРІРѕРё
```
GET http://localhost:3000/api/beam_deflections
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### 5. Complete Р·Р°СЏРІРєРё (РѕР±С‹С‡РЅС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ) в†’ 403
```
PUT http://localhost:3000/api/beam_deflections/52/complete
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4
```

### 6. Complete Р·Р°СЏРІРєРё (РјРѕРґРµСЂР°С‚РѕСЂ) в†’ 200 OK
```
PUT http://localhost:3000/api/beam_deflections/52/complete
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 7. GET Р·Р°СЏРІРєРё (РјРѕРґРµСЂР°С‚РѕСЂ) в†’ РІСЃРµ Р·Р°СЏРІРєРё
```
GET http://localhost:3000/api/beam_deflections
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 8. GET РґСЂР°С„С‚С‹ (РјРѕРґРµСЂР°С‚РѕСЂ) в†’ РІСЃРµ РґСЂР°С„С‚С‹ вњЁ РќРћР’РћР•
```
GET http://localhost:3000/api/beam_deflections?status=draft
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0
```

### 9. Sign Out (РґРѕР±Р°РІРёС‚СЊ С‚РѕРєРµРЅ РІ blacklist)
```
POST http://localhost:3000/api/auth/sign_out
Authorization: Bearer <С‚РѕРєРµРЅ_РґР»СЏ_Р±Р»РѕРєРёСЂРѕРІРєРё>
```

## Redis Commands

```bash
# РџРѕРєР°Р·Р°С‚СЊ РІСЃРµ РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "*"

# РџРѕРєР°Р·Р°С‚СЊ blacklist РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*"

# РџРѕР»СѓС‡РёС‚СЊ Р·РЅР°С‡РµРЅРёРµ РєР»СЋС‡Р°
docker-compose exec redis redis-cli GET "jwt:blacklist:<hash>"

# РџРѕРєР°Р·Р°С‚СЊ TTL РєР»СЋС‡Р°
docker-compose exec redis redis-cli TTL "jwt:blacklist:<hash>"

# РџРѕРґСЃС‡РёС‚Р°С‚СЊ РєРѕР»РёС‡РµСЃС‚РІРѕ blacklist РєР»СЋС‡РµР№
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*" | wc -l

# Redis СЃС‚Р°С‚РёСЃС‚РёРєР°
docker-compose exec redis redis-cli INFO stats

# РћС‡РёСЃС‚РёС‚СЊ РІСЃРµ blacklist РєР»СЋС‡Рё
docker-compose exec redis redis-cli KEYS "jwt:blacklist:*" | xargs docker-compose exec redis redis-cli DEL
```

## Rails Commands

```bash
# РџРѕРґРіРѕС‚РѕРІРёС‚СЊ demo РґР°РЅРЅС‹Рµ
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb

# РЎС‚Р°С‚РёСЃС‚РёРєР° РїРѕ Р·Р°СЏРІРєР°Рј
docker-compose exec web bin/rails runner "
puts 'Draft: #{BeamDeflection.draft.count}'
puts 'Formed: #{BeamDeflection.formed.count}'
puts 'Completed: #{BeamDeflection.completed.count}'
"

# РќР°Р№С‚Рё РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РїРѕ ID
docker-compose exec web bin/rails runner "puts User.find(39).inspect"

# Р”РµРєРѕРґРёСЂРѕРІР°С‚СЊ JWT (РїРѕРєР°Р·Р°С‚СЊ payload)
docker-compose exec web bin/rails runner "
token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4'
puts JwtToken.decode(token).inspect
"
```

## URLs

- **Swagger UI**: http://localhost:3000/api-docs
- **Web UI**: http://localhost:3000
- **API**: http://localhost:3000/api

## РџСЂРѕРІРµСЂРєР° ID Р·Р°СЏРІРѕРє РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

```bash
# РќР°Р№С‚Рё formed Р·Р°СЏРІРєСѓ РґР»СЏ completion
docker-compose exec web bin/rails runner "
bd = BeamDeflection.formed.first
puts \"Use ID: #{bd.id}\" if bd
"
```

## РЎР±СЂРѕСЃ РґРµРјРѕ-РґР°РЅРЅС‹С…

```bash
# РЈРґР°Р»РёС‚СЊ РІСЃРµ beam deflections
docker-compose exec web bin/rails runner "BeamDeflection.destroy_all"

# РџРµСЂРµСЃРѕР·РґР°С‚СЊ РґРµРјРѕ РґР°РЅРЅС‹Рµ
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb
```

