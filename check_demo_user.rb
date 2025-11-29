# Check demo user exists and can authenticate
puts "=" * 60
puts "Checking demo@local user..."
puts "=" * 60

user = User.find_by(email: 'demo@local')

if user
  puts "✓ User exists"
  puts "  ID: #{user.id}"
  puts "  Email: #{user.email}"
  puts "  Moderator: #{user.moderator?}"
  puts ""

  # Try to authenticate with 'password'
  if user.authenticate('password')
    puts "✓ Authentication with 'password' works!"
  else
    puts "✗ Authentication with 'password' FAILED"
    puts ""
    puts "Attempting to reset password to 'password'..."
    user.update!(password: 'password', password_confirmation: 'password')
    puts "✓ Password reset successful"
  end
else
  puts "✗ User does NOT exist"
  puts ""
  puts "Creating demo@local user..."
  user = User.create!(
    email: 'demo@local',
    password: 'password',
    password_confirmation: 'password'
  )
  puts "✓ User created (ID: #{user.id})"
end

puts ""
puts "=" * 60
puts "Credentials for Swagger:"
puts "  Email: demo@local"
puts "  Password: password"
puts "=" * 60
