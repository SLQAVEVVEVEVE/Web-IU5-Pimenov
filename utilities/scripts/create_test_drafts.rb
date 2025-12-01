# Create test drafts for different users
users = User.where(moderator: false).limit(3)
beam = Beam.available.first

unless beam
  puts "No beams available!"
  exit 1
end

puts "=" * 60
puts "Creating test beam_deflections with different statuses..."
puts "=" * 60
puts ""

created = []

users.each_with_index do |user, idx|
  # Create draft
  draft = user.beam_deflections.create!(
    status: 'draft',
    length_m: (3 + idx).to_f,
    udl_kn_m: (8 + idx * 2).to_f,
    note: "Draft заявка от #{user.email}"
  )

  draft.beam_deflection_beams.create!(
    beam: beam,
    quantity: idx + 1,
    position: 1
  )

  created << {
    id: draft.id,
    status: draft.status,
    creator: user.email
  }
end

puts "Created #{created.count} draft beam_deflections:"
created.each do |bd|
  puts "  - ID: #{bd[:id]}, Status: #{bd[:status]}, Creator: #{bd[:creator]}"
end

puts ""
puts "=" * 60
puts "Summary of all beam_deflections:"
puts "=" * 60

BeamDeflection.not_deleted.group(:status).count.each do |status, count|
  puts "  #{status}: #{count}"
end

puts ""
puts "Total non-deleted: #{BeamDeflection.not_deleted.count}"
puts ""
puts "=" * 60
puts "Now test in Swagger:"
puts "=" * 60
puts ""
puts "1. Sign in as moderator:"
puts "   POST /api/auth/sign_in"
puts "   {\"email\": \"moderator@example.com\", \"password\": \"password123\"}"
puts ""
puts "2. Get all beam_deflections (including drafts):"
puts "   GET /api/beam_deflections"
puts ""
puts "3. Filter by status:"
puts "   GET /api/beam_deflections?status=draft"
puts ""
