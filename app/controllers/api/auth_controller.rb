module Api
  class AuthController < BaseController
    skip_before_action :authenticate_request, only: [:sign_in, :sign_up]
    before_action :require_auth!, only: [:sign_out, :me]
    
    def sign_in
      user = User.find_by(email: login_params[:email])

      if user&.authenticate(login_params[:password])
        render_token_response(user)
      else
        render_error('Invalid email or password', :unauthorized)
      end
    end
    
    def sign_up
      user = User.new(signup_params)

      if user.save
        render_token_response(user, :created)
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def sign_out
      token = bearer_token

      if token.present? && JwtToken.blacklist!(token)
        Rails.logger.info "[Auth] Token blacklisted for user #{Current.user&.id}"
        render json: { message: 'Successfully signed out' }, status: :ok
      else
        Rails.logger.warn "[Auth] Failed to blacklist token for user #{Current.user&.id}"
        # Still return success even if blacklist fails (token will expire naturally)
        render json: { message: 'Signed out (token not blacklisted)' }, status: :ok
      end
    end
    
    def me
      render json: user_payload(Current.user)
    end
    
    private
    
    def login_params
      base = params[:user].is_a?(ActionController::Parameters) ? params.require(:user) : params
      base.permit(:email, :password).tap do |whitelisted|
        whitelisted[:email] = whitelisted[:email].to_s.downcase
      end
    end

    def signup_params
      base = params[:user].is_a?(ActionController::Parameters) ? params.require(:user) : params
      permitted = base.permit(:email, :password, :password_confirmation)
      permitted[:email] = permitted[:email].to_s.downcase
      permitted
    end

    def render_token_response(user, status = :ok)
      render json: {
        token: JwtToken.encode(token_payload(user)),
        user: user_payload(user)
      }, status: status
    end

    def token_payload(user)
      {
        user_id: user.id,
        email: user.email,
        exp: 24.hours.from_now.to_i
      }
    end

    def user_payload(user)
      {
        id: user.id,
        email: user.email,
        moderator: user.moderator?
      }
    end
  end
end
