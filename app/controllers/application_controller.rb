class ApplicationController < ActionController::Base
  helper_method :current_user, :current_draft
  before_action :set_cart_state
  helper MinioHelper
  
  private
  
  def current_user
    # Dev stub; replace with real auth later
    @current_user ||= User.first || User.create!(
      email: "dev@example.com", 
      password: "password",
      password_confirmation: "password"
    )
  end
  
  def current_draft
    @current_draft ||= Request.find_by(creator_id: current_user.id, status: "draft")
  end
  
  def set_cart_state
    draft = current_draft
    @cart_available = draft.present?
    @cart_items_count = draft ? draft.requests_services.sum(:quantity) : 0
    
    # For backward compatibility with existing views
    @order = { items: draft ? draft.requests_services.map { |rs| { qty: rs.quantity } } : [] }
    @basket_count = @cart_items_count
  end
  
  def require_user
    current_user || head(:unauthorized)
  end
end

