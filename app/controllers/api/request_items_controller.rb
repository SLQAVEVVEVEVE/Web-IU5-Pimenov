module Api
  class RequestItemsController < BaseController
    before_action :set_request

    def update_item
      service_id = params.require(:service_id)
      item = @request.requests_services.find_or_initialize_by(service_id: service_id)
      attrs = params.require(:request_service).permit(:quantity, :position, :deflection_mm)
      if item.update(attrs)
        render json: item
      else
        render_error(item.errors.full_messages, :unprocessable_entity)
      end
    end

    def remove_item
      service_id = params.require(:service_id)
      item = @request.requests_services.find_by!(service_id: service_id)
      item.destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    private

    def set_request
      @request = Request.find(params[:request_id])
    end
  end
end
