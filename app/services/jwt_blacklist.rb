# frozen_string_literal: true

# Service for managing JWT token blacklist using Redis
class JwtBlacklist
  BLACKLIST_PREFIX = 'jwt:blacklist:'

  class << self
    # Add a token to the blacklist
    # @param token [String] the JWT token to blacklist
    # @param exp [Integer] expiration timestamp (Unix timestamp)
    # @return [Boolean] true if successfully blacklisted
    def add(token, exp: nil)
      return false if token.blank?

      # Calculate TTL: time until token expires naturally
      ttl = if exp.present?
        exp - Time.now.to_i
      else
        # If no expiration provided, try to decode it from token
        payload = JwtToken.decode(token)
        payload ? payload[:exp] - Time.now.to_i : JwtToken::EXPIRATION.to_i
      end

      # Only blacklist if token hasn't expired yet
      return false if ttl <= 0

      redis.setex(key(token), ttl, '1')
      true
    rescue Redis::BaseError => e
      Rails.logger.error "[JwtBlacklist] Failed to add token: #{e.message}"
      false
    end

    # Check if a token is blacklisted
    # @param token [String] the JWT token to check
    # @return [Boolean] true if token is blacklisted
    def blacklisted?(token)
      return false if token.blank?

      redis.exists?(key(token))
    rescue Redis::BaseError => e
      Rails.logger.error "[JwtBlacklist] Failed to check token: #{e.message}"
      # On Redis error, fail open (don't block valid tokens)
      false
    end

    # Remove a token from blacklist (rarely needed, as TTL handles this)
    # @param token [String] the JWT token to remove
    # @return [Boolean] true if removed
    def remove(token)
      return false if token.blank?

      redis.del(key(token)) > 0
    rescue Redis::BaseError => e
      Rails.logger.error "[JwtBlacklist] Failed to remove token: #{e.message}"
      false
    end

    # Get count of blacklisted tokens (for monitoring)
    # @return [Integer] number of blacklisted tokens
    def count
      redis.keys("#{BLACKLIST_PREFIX}*").size
    rescue Redis::BaseError => e
      Rails.logger.error "[JwtBlacklist] Failed to count tokens: #{e.message}"
      0
    end

    # Clear all blacklisted tokens (use with caution!)
    # @return [Integer] number of tokens cleared
    def clear_all
      keys = redis.keys("#{BLACKLIST_PREFIX}*")
      return 0 if keys.empty?

      redis.del(*keys)
    rescue Redis::BaseError => e
      Rails.logger.error "[JwtBlacklist] Failed to clear tokens: #{e.message}"
      0
    end

    private

    # Generate Redis key for a token
    # @param token [String] the JWT token
    # @return [String] Redis key
    def key(token)
      # Use SHA256 hash to keep keys uniform length and avoid storing full token
      token_hash = Digest::SHA256.hexdigest(token)
      "#{BLACKLIST_PREFIX}#{token_hash}"
    end

    # Get Redis connection from Rails config
    # @return [Redis] Redis connection
    def redis
      Rails.application.config.redis
    end
  end
end
