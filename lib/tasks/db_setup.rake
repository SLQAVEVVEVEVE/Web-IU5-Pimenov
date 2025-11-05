namespace :db do
  desc 'Set up the database'
  task setup: :environment do
    puts 'Setting up the database...'
    
    # Load Rails environment
    require_relative '../../config/environment'
    
    # Check if the database exists
    begin
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection
      puts 'Database already exists.'
    rescue ActiveRecord::NoDatabaseError => e
      puts 'Creating database...'
      Rake::Task['db:create'].invoke
    rescue => e
      puts "Error: #{e.message}"
      puts 'Please make sure the database server is running and accessible.'
      exit 1
    end
    
    # Run migrations
    puts 'Running migrations...'
    Rake::Task['db:migrate'].invoke
    
    puts 'Database setup complete!'
  end
end
