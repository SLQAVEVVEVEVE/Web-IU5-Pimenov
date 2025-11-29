# frozen_string_literal: true

class JwtToken
  SECRET_KEY = ENV['SECRET_KEY_BASE'] || Rails.application.secret_key_base || Rails.application.credentials.secret_key_base
  ALGORITHM = 'HS256'.freeze
  EXPIRATION = 24.hours

  class << self
    def encode(payload, exp = EXPIRATION.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode(token, check_blacklist: true)
      # Check blacklist first (if enabled)
      if check_blacklist && blacklisted?(token)
        Rails.logger.warn("JWT Error: Token is blacklisted")
        return nil
      end

      body = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM }).first
      ActiveSupport::HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.error("JWT Error: #{e.message}")
      nil
    end

    # Check if token is in blacklist
    # @param token [String] the JWT token
    # @return [Boolean] true if blacklisted
    def blacklisted?(token)
      return false if token.blank?

      # Only check blacklist if JwtBlacklist is available
      return false unless defined?(JwtBlacklist)

      JwtBlacklist.blacklisted?(token)
    end

    # Add token to blacklist (typically called on sign out)
    # @param token [String] the JWT token
    # @return [Boolean] true if successfully blacklisted
    def blacklist!(token)
      return false if token.blank?
      return false unless defined?(JwtBlacklist)

      # Get expiration from token
      payload = decode(token, check_blacklist: false)
      return false unless payload

      JwtBlacklist.add(token, exp: payload[:exp])
    end
  end
end
