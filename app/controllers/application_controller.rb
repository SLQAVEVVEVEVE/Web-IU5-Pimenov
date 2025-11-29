class ApplicationController < ActionController::Base
  helper_method :current_user, :current_draft
  before_action :set_current_user
  before_action :set_cart_state
  helper MinioHelper
  
  private
  
  def set_current_user
    Current.user = current_user if current_user
  end
  
  def current_user
    # For API requests, we'll use the token-based auth
    return @current_user if defined?(@current_user)
    
    # For web interface, fall back to the first user or create a demo user
    @current_user = User.first || User.create!(
      email: "demo@local",
      password: "password",
      password_confirmation: "password"
    )
  end
  
  def current_draft
    @current_draft ||= current_user.beam_deflections.draft.first_or_create! do |bd|
      bd.status = :draft
    end
  end
  
  def set_cart_state
    @cart_beams_count = current_draft.beam_deflection_beams.sum(:quantity)
  end
  
  def require_login
    unless current_user
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Please log in first" }
        format.json { render json: { error: "Please log in first" }, status: :unauthorized }
      end
    end
  end
end

