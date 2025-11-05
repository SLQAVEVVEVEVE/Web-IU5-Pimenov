namespace :db do
  desc "Print nullability of requests.length_m and udl_kn_m"
  task check_nulls: :environment do
    cols = ActiveRecord::Base.connection.columns(:requests)
    lm = cols.find { |c| c.name == "length_m" }
    q  = cols.find { |c| c.name == "udl_kn_m" }
    puts "length_m null? => #{lm&.null.inspect}, default => #{lm&.default.inspect}"
    puts "udl_kn_m null? => #{q&.null.inspect}, default => #{q&.default.inspect}"
  end
end
