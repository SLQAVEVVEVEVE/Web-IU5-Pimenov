# Test API endpoint for viewing drafts as moderator

require 'net/http'
require 'json'
require 'uri'

# Find moderator
moderator = User.find_by(email: "moderator@test.com")
unless moderator
  puts "ERROR: Moderator not found!"
  exit 1
end

# Generate JWT token
token = JwtToken.encode(user_id: moderator.id, exp: 24.hours.from_now.to_i)

# Make API request
uri = URI('http://localhost:3000/api/beam_deflections?status=draft')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"

puts "Making request to: #{uri}"
puts "As moderator: #{moderator.email}"
puts ""

response = http.request(request)

puts "Response status: #{response.code}"
puts "Response body:"
data = JSON.parse(response.body)
puts JSON.pretty_generate(data)

# Count drafts
if data['beam_deflections']
  drafts = data['beam_deflections']
  puts ""
  puts "Total drafts returned: #{drafts.count}"
  puts "Creators: #{drafts.map { |d| d['creator_login'] }.uniq.join(', ')}"
end
