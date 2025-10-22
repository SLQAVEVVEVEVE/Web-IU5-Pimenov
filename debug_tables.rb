#!/usr/bin/env ruby

puts "=== DIAGNOSTIC CHECK ==="
puts "Checking current table names in models..."

begin
  require_relative 'config/environment'

  puts "Service.table_name: #{Service.table_name}"
  puts "Request.table_name: #{Request.table_name}"
  puts "RequestService.table_name: #{RequestService.table_name}"
  puts "User.table_name: #{User.table_name}"

  puts "\n=== DATA COUNTS ==="
  puts "Services: #{Service.count}"
  puts "Requests: #{Request.count}"
  puts "RequestServices: #{RequestService.count}"
  puts "Users: #{User.count}"

rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first
end
