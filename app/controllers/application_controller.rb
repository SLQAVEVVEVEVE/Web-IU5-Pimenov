class ApplicationController < ActionController::Base
  helper_method :current_requester_id, :current_draft_request, :cart_items_count, :cart_total_qty

  # Единый способ получить id пользователя-заказчика.
  # Если нет реальной авторизации, создаём/используем демо-пользователя.
  def current_requester_id
    # временно — демо-пользователь; при реальной аутентификации возвращай current_user.id
    User.first&.id || 1
  end

  def current_draft_request
    requester_id = current_requester_id
    return nil unless requester_id

    @current_draft_request ||= DeflectionRequest.find_by(
      requester_id: requester_id,
      status: DeflectionRequest::STATUS_DRAFT # или 0, если используете чистое число
    )
  end

  def cart_items_count(request = nil)
    request ||= current_draft_request
    return 0 unless request

    request.items.loaded? ? request.items.size : request.items.count
  end

  def cart_total_qty(request = nil)
    request ||= current_draft_request
    return 0 unless request

    request.items.sum(:quantity)
  end
end
