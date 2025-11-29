# Prepare demo data for presentation

puts "=== Preparing Demo Data ==="
puts ""

# 1. Create users
puts "1. Creating users..."
regular_user = User.find_or_create_by!(email: "user@demo.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.moderator = false
end
puts "   ✓ Regular user: #{regular_user.email} (password: password123)"

moderator = User.find_or_create_by!(email: "moderator@demo.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.moderator = true
end
puts "   ✓ Moderator: #{moderator.email} (password: password123)"

# 2. Create beams
puts ""
puts "2. Creating beams..."
beam1 = Beam.find_or_create_by!(name: "Wooden Beam 50x150") do |b|
  b.material = "wooden"
  b.elasticity_gpa = 12.0
  b.inertia_cm4 = 1500.0
  b.allowed_deflection_ratio = 250.0
end
puts "   ✓ #{beam1.name} (ID: #{beam1.id})"

beam2 = Beam.find_or_create_by!(name: "Steel Beam 100x200") do |b|
  b.material = "steel"
  b.elasticity_gpa = 200.0
  b.inertia_cm4 = 3500.0
  b.allowed_deflection_ratio = 300.0
end
puts "   ✓ #{beam2.name} (ID: #{beam2.id})"

# 3. Create beam deflections (requests) with different statuses
puts ""
puts "3. Creating beam deflections..."

# Draft from regular user
draft = BeamDeflection.create!(
  creator: regular_user,
  status: "draft",
  length_m: 5.0,
  udl_kn_m: 10.0,
  note: "Draft calculation"
)
draft.beam_deflection_beams.create!(beam: beam1, quantity: 2, position: 1)
puts "   ✓ Draft (ID: #{draft.id}) by #{regular_user.email}"

# Formed request from regular user
formed = BeamDeflection.create!(
  creator: regular_user,
  status: "formed",
  length_m: 6.0,
  udl_kn_m: 15.0,
  note: "Ready for review",
  formed_at: Time.current
)
formed.beam_deflection_beams.create!(beam: beam1, quantity: 1, position: 1)
formed.beam_deflection_beams.create!(beam: beam2, quantity: 1, position: 2)
puts "   ✓ Formed (ID: #{formed.id}) by #{regular_user.email}"

# Completed request
completed = BeamDeflection.create!(
  creator: regular_user,
  status: "completed",
  moderator: moderator,
  length_m: 4.0,
  udl_kn_m: 12.0,
  note: "Completed calculation",
  formed_at: 1.day.ago,
  completed_at: Time.current,
  result_deflection_mm: 2.5,
  within_norm: true
)
completed.beam_deflection_beams.create!(beam: beam1, quantity: 3, position: 1, deflection_mm: 2.5)
puts "   ✓ Completed (ID: #{completed.id}) by moderator #{moderator.email}"

# 4. Generate JWT tokens
puts ""
puts "4. JWT Tokens:"
user_token = JwtToken.encode(user_id: regular_user.id, exp: 24.hours.from_now.to_i)
moderator_token = JwtToken.encode(user_id: moderator.id, exp: 24.hours.from_now.to_i)

puts "   Regular user token (user@demo.com):"
puts "   #{user_token}"
puts ""
puts "   Moderator token (moderator@demo.com):"
puts "   #{moderator_token}"

# 5. Summary
puts ""
puts "=== Summary ==="
puts "Total users: #{User.count}"
puts "Total beams: #{Beam.count}"
puts "Total beam deflections: #{BeamDeflection.count}"
puts "  - Draft: #{BeamDeflection.draft.count}"
puts "  - Formed: #{BeamDeflection.formed.count}"
puts "  - Completed: #{BeamDeflection.completed.count}"
puts ""
puts "Ready for demonstration!"
