module Api
  module Requests
    class ItemsController < BaseController
      before_action :find_request
      before_action :validate_request_ownership
      
      def update
        # Get or create the request item
        request_item = @request.requests_services
                              .find_or_initialize_by(service_id: item_params[:service_id])
        
        # Update attributes
        request_item.quantity = item_params[:quantity].to_i if item_params.key?(:quantity)
        request_item.position = item_params[:position].to_i if item_params.key?(:position)
        
        # Validate quantity
        if request_item.quantity.present? && request_item.quantity <= 0
          return render_error('Quantity must be greater than 0', :unprocessable_entity)
        end
        
        if request_item.save
          render json: {
            id: request_item.id,
            service_id: request_item.service_id,
            quantity: request_item.quantity,
            position: request_item.position
          }
        else
          render_error(request_item.errors.full_messages, :unprocessable_entity)
        end
      end
      
      def destroy
        # Find the request item by service_id
        request_item = @request.requests_services.find_by(service_id: params[:service_id])
        
        if request_item.nil?
          return render_error('Item not found in this request', :not_found)
        end
        
        if request_item.destroy
          head :no_content
        else
          render_error('Failed to remove item from request', :unprocessable_entity)
        end
      end
      
      private
      
      def find_request
        @request = Request.not_deleted.find(params[:request_id])
      rescue ActiveRecord::RecordNotFound
        render_error('Request not found', :not_found)
      end
      
      def validate_request_ownership
        # Only allow updates to draft requests owned by the current user
        unless @request.draft? && @request.creator == Current.user
          render_error('You can only modify your own draft requests', :forbidden)
        end
      end
      
      def item_params
        params.require(:item).permit(:service_id, :quantity, :position)
      end
    end
  end
end
