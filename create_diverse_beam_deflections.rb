# Create beam_deflections with different statuses
users = [
  User.find_by(email: 'demo@local'),
  User.find_by(email: 'test@example.com'),
  User.find_by(email: 'user@example.com')
].compact

beam = Beam.available.first

unless beam
  puts "No beams available!"
  exit 1
end

moderator = User.find_by(email: 'moderator@example.com')

puts "=" * 60
puts "Creating test beam_deflections..."
puts "=" * 60
puts ""

created = []

# User 1: formed beam_deflection
user1 = users[0]
if user1
  bd1 = user1.beam_deflections.create!(
    status: 'formed',
    length_m: 6.0,
    udl_kn_m: 12.0,
    note: "Formed заявка от #{user1.email}",
    formed_at: Time.current
  )
  bd1.beam_deflection_beams.create!(beam: beam, quantity: 2, position: 1)
  created << {id: bd1.id, status: bd1.status, creator: user1.email}
end

# User 2: completed beam_deflection
user2 = users[1]
if user2
  bd2 = user2.beam_deflections.create!(
    status: 'completed',
    length_m: 5.0,
    udl_kn_m: 10.0,
    note: "Completed заявка от #{user2.email}",
    formed_at: 1.day.ago,
    completed_at: Time.current,
    moderator: moderator,
    result_deflection_mm: 2.5
  )
  bd2.beam_deflection_beams.create!(beam: beam, quantity: 1, position: 1, deflection_mm: 2.5)
  created << {id: bd2.id, status: bd2.status, creator: user2.email}
end

# User 3: rejected beam_deflection
user3 = users[2]
if user3
  bd3 = user3.beam_deflections.create!(
    status: 'rejected',
    length_m: 4.0,
    udl_kn_m: 8.0,
    note: "Rejected заявка от #{user3.email}",
    formed_at: 2.days.ago,
    completed_at: Time.current,
    moderator: moderator
  )
  bd3.beam_deflection_beams.create!(beam: beam, quantity: 3, position: 1)
  created << {id: bd3.id, status: bd3.status, creator: user3.email}
end

puts "✓ Created #{created.count} beam_deflections:"
created.each do |bd|
  puts "  - ID: #{bd[:id]}, Status: #{bd[:status]}, Creator: #{bd[:creator]}"
end

puts ""
puts "=" * 60
puts "Summary:"
puts "=" * 60

BeamDeflection.not_deleted.group(:status).count.each do |status, count|
  puts "  #{status}: #{count}"
end

puts ""
puts "Total non-deleted: #{BeamDeflection.not_deleted.count}"
puts ""
puts "=" * 60
puts "Now test in Swagger as MODERATOR:"
puts "=" * 60
puts ""
puts "1. POST /api/auth/sign_in"
puts "   {\"email\": \"moderator@example.com\", \"password\": \"password123\"}"
puts ""
puts "2. GET /api/beam_deflections"
puts "   Should see ALL statuses: draft, formed, completed, rejected"
puts ""
puts "3. Filter by status:"
puts "   GET /api/beam_deflections?status=draft"
puts "   GET /api/beam_deflections?status=formed"
puts "   GET /api/beam_deflections?status=completed"
puts "   GET /api/beam_deflections?status=rejected"
puts ""
