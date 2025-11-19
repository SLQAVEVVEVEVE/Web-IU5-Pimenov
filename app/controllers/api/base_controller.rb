module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds
    #respond_to :json

    before_action :force_json
    before_action :authenticate_request

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def force_json
      request.format = :json
    end

    def authenticate_request
      token = bearer_token

      if token.present?
        payload = JwtToken.decode(token)
        user = payload && User.find_by(id: payload[:user_id])
        if user
          assign_current_user(user)
          return
        else
          return render_error('Invalid or expired token', :unauthorized)
        end
      end

      # No token provided: fall back to demo user for LR3 compatibility
      assign_current_user(User.demo_user)
    end

    def bearer_token
      header = request.headers['Authorization']
      return if header.blank?

      token = header.to_s.split(' ', 2).last || header
      token = token.strip
      token = token[1..-2] if token.start_with?('"') && token.end_with?('"')
      token
    end

    def assign_current_user(user)
      @current_user = user
      Current.user = user if defined?(Current)
    end

    def current_user
      @current_user
    end

    def render_error(message, status)
      render json: { error: message }, status: status
    end

    def not_found
      render json: { error: 'Resource not found' }, status: :not_found
    end

    def forbidden
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
end
