# Create test beam deflection for demo purposes
user = User.find_by(email: 'demo@local')
beam = Beam.available.first

unless beam
  puts "No beams available! Please create a beam first."
  exit 1
end

# Create a formed beam_deflection
bd = user.beam_deflections.create!(
  status: 'formed',
  length_m: 5.0,
  udl_kn_m: 10.0,
  note: 'Тестовая заявка для API',
  formed_at: Time.current
)

# Add a beam to it
bd.beam_deflection_beams.create!(
  beam: beam,
  quantity: 2,
  position: 1
)

puts "=" * 60
puts "Test beam_deflection created!"
puts "  ID: #{bd.id}"
puts "  Status: #{bd.status}"
puts "  Creator: #{bd.creator.email}"
puts "  Beams: #{bd.beams.count}"
puts "=" * 60
puts ""
puts "Now try in Swagger:"
puts "  GET /api/beam_deflections"
puts ""
puts "You should see this beam_deflection in the list!"
