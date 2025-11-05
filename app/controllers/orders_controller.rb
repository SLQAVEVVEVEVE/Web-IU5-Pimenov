class OrdersController < ApplicationController
  include MinioHelper
  helper_method :minio_image_url
  
  before_action :set_request, only: [:show, :complete]

  # GET /orders/:id
  def show
    @items = @request.requests_services.includes(:service).order(:id)
  end
  
  # POST /orders/:id/complete
  def complete
    # In a real app, add authorization check here (e.g., check if user is a moderator)
    Request.transaction do
      @request.update!(
        status: Request::STATUSES[:completed],
        completed_at: Time.current,
        moderator: current_user
      )
      @request.compute_and_store_result_deflection!
    end
    
    redirect_to order_path(@request), notice: "Заявка завершена, прогиб рассчитан."
  rescue => e
    Rails.logger.error "Failed to complete order: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to order_path(@request), alert: "Не удалось завершить заявку: #{e.message}"
  end
  
  private
  
  def set_request
    @request = Request.find(params[:id])
    # Uncomment to hide deleted requests
    # redirect_to root_path, alert: "Заявка не найдена" if @request.deleted?
  end
end
