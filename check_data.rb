#!/usr/bin/env ruby

puts "Checking data preservation after table rename..."
puts "=" * 50

begin
  require_relative 'config/environment'

  puts "Services (types count): #{Service.count}"
  puts "Requests (orders count): #{Request.count}"
  puts "RequestServices (order items count): #{RequestService.count}"
  puts "Users count: #{User.count}"

  if Service.count > 0
    puts "\nSample service:"
    service = Service.first
    puts "  ID: #{service.id}"
    puts "  Name: #{service.name}"
    puts "  Material: #{service.material}"
  end

  if Request.count > 0
    puts "\nSample request:"
    request = Request.first
    puts "  ID: #{request.id}"
    puts "  Status: #{request.status}"
    puts "  Requester ID: #{request.requester_id}"
  end

  if RequestService.count > 0
    puts "\nSample request service:"
    rs = RequestService.first
    puts "  ID: #{rs.id}"
    puts "  Request ID: #{rs.request_id}"
    puts "  Service ID: #{rs.service_id}"
    puts "  Length: #{rs.length_m}m"
    puts "  Load: #{rs.load_kn_m}kN/m"
  end

rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.first
end
