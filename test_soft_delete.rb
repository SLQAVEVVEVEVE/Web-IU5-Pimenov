puts 'Testing soft delete...'
item = LoadForecastBeamType.first
if item
  puts 'Found item'
  item.soft_delete
  puts 'Soft deleted'
  puts "Deleted?: #{item.deleted?}"
else
  puts 'No items found'
end
