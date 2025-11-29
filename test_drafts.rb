# Test script to create draft beam deflections for different users

# Create moderator
moderator = User.find_or_create_by!(email: "moderator@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.moderator = true
end

# Create regular users
user1 = User.find_or_create_by!(email: "user1@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.moderator = false
end

user2 = User.find_or_create_by!(email: "user2@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.moderator = false
end

# Create drafts for different users
draft1 = BeamDeflection.create!(creator: user1, status: "draft", length_m: 5.0, udl_kn_m: 10.0)
draft2 = BeamDeflection.create!(creator: user2, status: "draft", length_m: 3.0, udl_kn_m: 15.0)

puts "Created:"
puts "Moderator: #{moderator.email} (ID: #{moderator.id})"
puts "User1: #{user1.email} (ID: #{user1.id}), draft: #{draft1.id}"
puts "User2: #{user2.email} (ID: #{user2.id}), draft: #{draft2.id}"
puts "Total drafts: #{BeamDeflection.draft.not_deleted.count}"
