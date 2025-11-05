module Api
  class SessionsController < Api::BaseController
    skip_before_action :authenticate_user!, only: [:create]
    
    # POST /api/users/login
    def create
      @user = User.find_by(email: params[:email].to_s.downcase)
      
      if @user&.authenticate(params[:password])
        render json: {
          user: {
            id: @user.id,
            email: @user.email,
            role: @user.role
          },
          token: @user.generate_jwt
        }, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
    
    # POST /api/users/logout
    def destroy
      # JWT is stateless, so we just return success
      # In a real app, you might want to implement token blacklisting
      head :no_content
    end
  end
end
