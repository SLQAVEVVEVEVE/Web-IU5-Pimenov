#!/usr/bin/env ruby

require_relative '../config/boot'
require_relative '../config/environment'

puts "Setting up the database..."

begin
  # Try to connect to the database
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.connection
  puts "Database connection successful."
rescue ActiveRecord::NoDatabaseError
  puts "Database does not exist. Creating it..."
  system('bin/rails db:create')
  
  # Re-establish connection
  ActiveRecord::Base.establish_connection
  
  # Run migrations
  puts "Running migrations..."
  system('bin/rails db:migrate')
  
  puts "Database setup complete!"
rescue => e
  puts "Error: #{e.message}"
  puts "Please make sure the database server is running and accessible."
  exit 1
end
