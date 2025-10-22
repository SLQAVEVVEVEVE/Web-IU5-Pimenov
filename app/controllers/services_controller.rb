class ServicesController < ApplicationController
  helper_method :cart_items_count, :cart_total_qty
  before_action :set_draft
  # HTML + JSON (если понадобится отдать справочник для фронта)
  def index
    @q = params[:q].to_s.strip
    scope = Service.active.order(:id)
    scope = scope.where("LOWER(name) LIKE ?", "%#{@q.downcase}%") if @q.present?
    @services = scope

    respond_to do |format|
      format.html # рендерит ваши текущие вьюхи index.html.erb
      format.json { render json: @services.select(:id, :name, :material, :elasticity_gpa, :norm, :image_key) }
    end
  end

  def show
    @service = Service.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service.slice(:id, :name, :material, :elasticity_gpa, :norm, :image_key, :deleted_at) }
    end
  end

  private

  def set_draft
    @draft = Requests::EnsureDraft.new(user_id: current_user_id).call
  end
  # ===== «Корзина» теперь на Request + request_services =====

  # кол-во строк в текущем черновике
  def cart_items_count(request = current_draft_request)
    return 0 unless request
    items = request.request_services
    items.loaded? ? items.size : items.count
  end

  # суммарное количество (quantity) по строкам черновика
  def cart_total_qty(request = current_draft_request)
    return 0 unless request
    items = request.request_services
    items.loaded? ? items.sum(&:quantity) : items.sum(:quantity)
  end

  # текущий черновик расчёта — статус :pending (0)
  def current_draft_request
    Request.active.where(requester_id: current_user_id, status: 0).first
  end

  # демо: вместо current_user.id
  def current_user_id
    # здесь можешь подставить current_user&.id, если Devise/own auth уже подключена
    1
  end
end
