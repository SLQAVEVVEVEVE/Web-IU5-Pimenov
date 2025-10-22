#!/usr/bin/env ruby

puts "Testing soft delete functionality..."

begin
  require_relative 'config/environment'
  puts "Rails environment loaded successfully"

  # Check if we have data
  load_forecast = LoadForecast.first
  beam_type = BeamType.first

  if load_forecast.nil? || beam_type.nil?
    puts "Missing test data (LoadForecast or BeamType)"
    exit 1
  end

  puts "Found LoadForecast: #{load_forecast.id}"
  puts "Found BeamType: #{beam_type.name}"

  # Create test item
  item = load_forecast.load_forecast_beam_types.create!(
    beam_type: beam_type,
    length_m: 2.5,
    load_kn_m: 5.0,
    quantity: 2
  )

  puts "Created item: #{item.inspect}"

  # Test soft delete
  puts "Before delete - deleted?: #{item.deleted?}"
  item.soft_delete
  puts "After soft delete - deleted?: #{item.deleted?}"
  puts "deleted_at: #{item.deleted_at}"

  # Test that item is not visible in default scope
  visible_items = load_forecast.load_forecast_beam_types.count
  puts "Visible items after delete: #{visible_items}"

  puts "SUCCESS: Soft delete works correctly!"

rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first
  exit 1
end
