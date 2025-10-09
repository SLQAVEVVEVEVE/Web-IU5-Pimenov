class BeamTypesController < ApplicationController
  helper_method :cart_items_count, :cart_total_qty

  def index
    @q = params[:q].to_s.strip
    scope = BeamType.all.order(:id)
    scope = scope.where("LOWER(name) LIKE ?", "%#{@q.downcase}%") if @q.present?
    @beam_types = scope
  end

  def show
    @beam_type = BeamType.find(params[:id]) # ORM
  end

  private

  # счет для корзины
  def cart_items_count(request = current_draft_request)
    return 0 unless request
    request.items.loaded? ? request.items.size : request.items.count
  end

  def cart_total_qty(request = current_draft_request)
    return 0 unless request
    if request.items.loaded?
      request.items.sum(&:quantity)
    else
      request.items.sum(:quantity)
    end
  end

  def current_draft_request
    DeflectionRequest.find_by(requester_id: current_user_id,
                              status: DeflectionRequest::STATUS_DRAFT)
  end

  def current_user_id
    1
  end
end
