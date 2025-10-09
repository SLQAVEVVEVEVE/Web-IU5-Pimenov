module ApplicationHelper
  # Сколько разных позиций (карточек) в заявке
  def cart_items_count(request = current_draft_request)
    return 0 unless request
    request.items.loaded? ? request.items.length : request.items.count
  end

  # Сколько штук всего (если где-то понадобится именно сумма quantity)
  def cart_total_qty(request = current_draft_request)
    return 0 unless request
    request.items.sum(:quantity)
  end
end
