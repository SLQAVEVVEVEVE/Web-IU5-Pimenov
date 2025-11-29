# Create moderator user
email = "moderator@example.com"
password = "password123"

user = User.find_by(email: email)

if user
  unless user.moderator?
    user.update!(moderator: true)
    puts "Updated existing user to moderator"
  end
else
  user = User.create!(
    email: email,
    password: password,
    password_confirmation: password,
    moderator: true
  )
  puts "Created new moderator user"
end

puts ""
puts "=" * 60
puts "Moderator credentials:"
puts "  Email: #{user.email}"
puts "  Password: #{password}"
puts "  Moderator: #{user.moderator?}"
puts "=" * 60
puts ""
puts "Use these credentials in Swagger:"
puts "1. POST /api/auth/sign_in with:"
puts "   {"
puts "     \"email\": \"#{user.email}\","
puts "     \"password\": \"#{password}\""
puts "   }"
puts ""
puts "2. Moderators see ALL beam_deflections (not just their own)"
puts ""

# Show all beam_deflections in system
all_deflections = BeamDeflection.not_deleted.not_draft
puts "Total beam_deflections in system (excluding draft/deleted): #{all_deflections.count}"

all_deflections.group(:status).count.each do |status, count|
  puts "  - #{status}: #{count}"
end
