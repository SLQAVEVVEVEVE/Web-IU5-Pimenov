#!/usr/bin/env ruby

puts 'Testing soft delete functionality...'

# Загружаем Rails окружение
require_relative 'config/environment'

puts 'Environment loaded'

# Находим первую заявку
load_forecast = LoadForecast.first
if load_forecast.nil?
  puts 'No load forecasts found'
  exit
end

puts "Found load forecast: #{load_forecast.id}"

# Находим первый тип балки
beam_type = BeamType.first
if beam_type.nil?
  puts 'No beam types found'
  exit
end

puts "Found beam type: #{beam_type.name}"

# Создаем тестовый элемент
begin
  item = load_forecast.load_forecast_beam_types.create!(
    beam_type: beam_type,
    length_m: 1.0,
    load_kn_m: 1.0,
    quantity: 1
  )
  puts "Created item: #{item.inspect}"

  # Тестируем мягкое удаление
  item.soft_delete
  puts "Soft deleted successfully"
  puts "Deleted?: #{item.deleted?}"
  puts "deleted_at: #{item.deleted_at}"

rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
end
