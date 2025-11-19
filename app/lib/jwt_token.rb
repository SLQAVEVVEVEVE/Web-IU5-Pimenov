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

    def decode(token)
      body = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM }).first
      ActiveSupport::HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.error("JWT Error: #{e.message}")
      nil
    end
  end
end
