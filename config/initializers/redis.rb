# frozen_string_literal: true

# Redis configuration for JWT blacklist and caching
Rails.application.configure do
  config.redis = Redis.new(
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    timeout: 1,
    reconnect_attempts: 3
  )
end

# Test connection on initialization
begin
  Rails.application.config.redis.ping
  Rails.logger.info "[Redis] Successfully connected to #{ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')}"
rescue Redis::CannotConnectError => e
  Rails.logger.error "[Redis] Failed to connect: #{e.message}"
  Rails.logger.warn "[Redis] JWT blacklist will not work without Redis connection"
end
