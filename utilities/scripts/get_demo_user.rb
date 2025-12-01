# Get or create demo user
user = User.find_by(email: 'demo@local')

if user
  puts "Demo user exists:"
  puts "  Email: #{user.email}"
  puts "  ID: #{user.id}"
  puts "  Password: password"
  puts ""
  puts "Checking beam_deflections..."

  deflections = user.beam_deflections.where.not(status: 'draft')
  puts "  Total beam_deflections (excluding draft): #{deflections.count}"

  deflections.each do |bd|
    puts "    - ID: #{bd.id}, Status: #{bd.status}, Created: #{bd.created_at}"
  end
else
  puts "Demo user not found. Creating..."
  user = User.create!(
    email: "demo@local",
    password: "password",
    password_confirmation: "password"
  )
  puts "Created demo user: #{user.email} (ID: #{user.id})"
end
