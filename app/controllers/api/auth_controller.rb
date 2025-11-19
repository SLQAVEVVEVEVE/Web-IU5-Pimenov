module Api
  class AuthController < BaseController
    skip_before_action :authenticate_request, only: [:sign_in, :sign_up]
    
    def sign_in
      creds = login_params
      user = User.find_by(email: creds[:email])
      
      if user&.authenticate(creds[:password])
        token = generate_token(user)
        render json: { 
          token: token,
          user: {
            id: user.id,
            email: user.email,
            moderator: user.moderator?
          }
        }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
    
    def sign_up
      user = User.new(signup_params)
      
      if user.save
        token = generate_token(user)
        render json: { 
          token: token,
          user: {
            id: user.id,
            email: user.email,
            moderator: user.moderator?
          }
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def sign_out
      # JWT is stateless, so we just return success
      head :no_content
    end
    
    def me
      render json: {
        id: current_user.id,
        email: current_user.email,
        moderator: current_user.moderator?
      }
    end
    
    private
    
    def login_params
      if params[:user].is_a?(ActionController::Parameters)
        params.require(:user).permit(:email, :password)
      else
        params.permit(:email, :password)
      end
    end

    def signup_params
      if params[:user].is_a?(ActionDispatch::Http::UploadedFile)
        # never happens here; keep normal branch
        params.permit(:email, :password, :password_confirmation)
      elsif params[:user].is_a?(ActionController::Parameters)
        params.require(:user).permit(:email, :password, :password_confirmation)
      else
        params.permit(:email, :password, :password_confirmation)
      end
    end
    
    def generate_token(user)
      payload = {
        user_id: user.id,
        email: user.email,
        exp: 24.hours.from_now.to_i
      }
      JwtToken.encode(payload)
    end
  end
end
