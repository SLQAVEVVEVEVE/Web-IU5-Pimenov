class CartItemsController < ApplicationController
  before_action :require_user

  def create
    service = Service.available.find_by(id: params[:service_id])
    return redirect_back fallback_location: services_path, alert: "Услуга недоступна." unless service

    RequestsService.transaction do
      draft = Request.find_by(creator_id: current_user.id, status: "draft") ||
              Request.create!(creator_id: current_user.id, status: "draft")
      
      rs = RequestsService.lock.find_by(request_id: draft.id, service_id: service.id)
      qty = (params[:quantity].presence || 1).to_i
      
      if rs
        rs.update!(quantity: rs.quantity + qty)
      else
        RequestsService.create!(
          request_id: draft.id,
          service_id: service.id,
          quantity: qty,
          position: (params[:position].presence || 1).to_i,
          is_primary: false  # Always set to false for new items
        )
      end
    end

    redirect_to cart_path, notice: "Услуга добавлена в заявку."
  end

  private
  
  def require_user
    current_user || head(:unauthorized)
  end
end
