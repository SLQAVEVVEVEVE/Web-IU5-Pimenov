module Api
  class MeController < BaseController
    before_action :require_auth!

    def show
      render json: current_user_payload
    end
    
    def update
      if Current.user.update(me_params)
        render json: current_user_payload
      else
        render json: { errors: Current.user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private
    
    def current_user_payload
      {
        id: Current.user.id,
        email: Current.user.email,
        moderator: Current.user.moderator?
      }
    end

    def me_params
      params.permit(:email, :password, :password_confirmation)
    end
  end
end
