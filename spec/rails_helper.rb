# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
abort("Rails env is #{Rails.env}") if Rails.env.production?

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end