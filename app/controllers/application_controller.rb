class ApplicationController < ActionController::Base
  helper_method :cart_items_count, :cart_total_qty, :current_draft_request

  def cart_items_count(request = current_draft_request)
    return 0 unless request
    items = request.request_services
    items.loaded? ? items.size : items.count
  end

  def cart_total_qty(request = current_draft_request)
    return 0 unless request
    items = request.request_services
    items.loaded? ? items.sum(&:quantity) : items.sum(:quantity)
  end

  def current_draft_request
    Requests::EnsureDraft.new(user_id: current_user_id).call
  end

  # временно
  def current_user_id
    1
  end
end
