module Api
  class RequestServicesController < Api::BaseController
    before_action :ensure_draft_request
    before_action :set_request_service, only: [:update, :destroy]

    # POST /api/request_services
    def create
      @request_service = @request.requests_services.find_or_initialize_by(
        service_id: request_service_params[:service_id]
      )
      
      # If service already exists in cart, increment quantity
      if @request_service.persisted?
        @request_service.quantity += (request_service_params[:quantity] || 1).to_i
      else
        @request_service.quantity = (request_service_params[:quantity] || 1).to_i
      end
      
      if @request_service.save
        render json: @request_service, status: :created
      else
        render json: { errors: @request_service.errors.full_messages }, 
               status: :unprocessable_entity
      end
    end

    # PUT /api/request_services
    def update
      if @request_service.update(request_service_params)
        render json: @request_service
      else
        render json: { errors: @request_service.errors.full_messages }, 
               status: :unprocessable_entity
      end
    end

    # DELETE /api/request_services
    def destroy
      @request_service.destroy
      head :no_content
    end

    # POST /api/request_services/add_to_cart
    # Simplified endpoint for frontend to add/update service in cart
    def add_to_cart
      service = Service.find_by(id: params[:service_id])
      return render json: { error: 'Service not found' }, status: :not_found unless service
      
      @request_service = @request.requests_services.find_or_initialize_by(service_id: service.id)
      
      if params[:quantity].to_i <= 0
        @request_service.destroy
        head :no_content
      else
        @request_service.quantity = params[:quantity].to_i
        
        if @request_service.save
          render json: @request_service
        else
          render json: { errors: @request_service.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end
    end

    private

    def ensure_draft_request
      @request = Request.draft_for(Current.user).first_or_initialize(creator: Current.user)
      @request.save! if @request.new_record?
    end

    def set_request_service
      @request_service = @request.requests_services.find_by(service_id: params[:id])
      return if @request_service
      
      render json: { error: 'Service not found in request' }, status: :not_found
    end

    def request_service_params
      params.require(:request_service).permit(:service_id, :quantity)
    end
  end
end
