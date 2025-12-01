puts '=== Проверка данных для демонстрации ==='
puts ''

# Пользователи
puts '1. Пользователи:'
user = User.find_by(email: 'user@demo.com')
mod = User.find_by(email: 'moderator@demo.com')
puts "   ✓ user@demo.com: ID=#{user&.id}, moderator=#{user&.moderator}"
puts "   ✓ moderator@demo.com: ID=#{mod&.id}, moderator=#{mod&.moderator}"

# Заявки
puts ''
puts '2. Заявки для демонстрации:'
formed = BeamDeflection.formed.where(creator: user).first
draft = BeamDeflection.draft.where(creator: user).first
completed = BeamDeflection.completed.first

puts "   Draft: ID=#{draft&.id}" if draft
puts "   Formed: ID=#{formed&.id} ← ДЛЯ COMPLETION" if formed
puts "   Completed: ID=#{completed&.id}" if completed

# Балки
puts ''
puts '3. Балки:'
puts "   Всего: #{Beam.count}"
Beam.limit(2).each do |b|
  puts "   - #{b.name} (ID: #{b.id})"
end

# Драфты для модератора
puts ''
puts '4. Все драфты (для просмотра модератором):'
puts "   Всего драфтов: #{BeamDeflection.draft.not_deleted.count}"

# JWT токены
puts ''
puts '5. Проверка JWT токенов:'
user_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozOSwiZXhwIjoxNzY0NTI5NTUwfQ.h61r9z0Rud3pyUVrYoNrO88wr-xf6Vq8Z8iJN1FFQV4'
mod_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0MCwiZXhwIjoxNzY0NTI5NTUwfQ.74Ud9dJZ1pPFzydT-yMWA-o5eqH0nOYmNlKiVtZJLl0'

begin
  user_payload = JwtToken.decode(user_token)
  puts "   ✓ User token valid: user_id=#{user_payload['user_id']}"
rescue => e
  puts "   ✗ User token invalid: #{e.message}"
end

begin
  mod_payload = JwtToken.decode(mod_token)
  puts "   ✓ Moderator token valid: user_id=#{mod_payload['user_id']}"
rescue => e
  puts "   ✗ Moderator token invalid: #{e.message}"
end

# Redis
puts ''
puts '6. Redis blacklist:'
begin
  redis = Rails.application.config.redis
  blacklist_keys = redis.keys('jwt:blacklist:*')
  puts "   Blacklisted tokens: #{blacklist_keys.count}"
rescue => e
  puts "   ✗ Redis error: #{e.message}"
end

puts ''
puts '=== Проверка завершена ==='
