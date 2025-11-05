module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds
    #respond_to :json

    before_action :force_json
    before_action :set_current_user

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def force_json
      request.format = :json
    end

    # LR3 simplified auth: fixed demo user to avoid auth 500s
    def set_current_user
      # LR3: fixate demo user for all API calls to keep ownership consistent
      @current_user = User.demo_user
      Current.user = @current_user if defined?(Current)
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
