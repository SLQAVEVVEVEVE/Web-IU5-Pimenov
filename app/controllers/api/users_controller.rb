module Api
  class UsersController < Api::BaseController
    skip_before_action :authenticate_user!, only: [:create, :login]
    
    # POST /api/users
    def create
      @user = User.new(user_params)
      
      if @user.save
        render json: {
          user: {
            id: @user.id,
            email: @user.email,
            role: @user.role
          },
          token: @user.generate_jwt
        }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    # GET /api/users/me
    def show_me
      render json: current_user, status: :ok
    end
    
    # PUT /api/users/me
    def update_me
      if current_user.update(user_params)
        render json: current_user, status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private
    
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :phone)
    end
  end
end
