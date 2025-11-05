namespace :db do
  desc 'Check requests_services table structure'
  task check_requests_services: :environment do
    if ActiveRecord::Base.connection.table_exists?(:requests_services)
      puts "requests_services table exists"
      puts "Columns:"
      puts ActiveRecord::Base.connection.columns('requests_services').map { |c| "- #{c.name}: #{c.type}" }
      
      # Check if there are any records
      count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM requests_services").first['count']
      puts "\nNumber of records in requests_services: #{count}"
      
      # Show sample data if any
      if count > 0
        puts "\nSample records (first 5):"
        records = ActiveRecord::Base.connection.execute("SELECT * FROM requests_services LIMIT 5")
        records.each do |record|
          puts record.inspect
        end
      end
    else
      puts "ERROR: requests_services table does not exist!"
    end
  end
end
