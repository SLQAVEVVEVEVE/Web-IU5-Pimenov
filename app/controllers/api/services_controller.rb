module Api
  class ServicesController < BaseController
    include MinioHelper
    before_action :set_service, only: [:show, :update, :destroy, :add_to_draft, :image]
    before_action :require_auth!, except: [:index, :show]
    before_action :require_moderator!, only: [:create, :update, :destroy, :image]
    
    def index
      # default: only active services; pass active=false to include inactive
      services = Service.all
      services = services.available unless params.key?(:active) && ActiveModel::Type::Boolean.new.cast(params[:active]) == false
      services = services.search(params[:q]) if services.respond_to?(:search)
      services = services.order(created_at: :desc)
      
      # Safely handle pagination
      page = [params[:page].to_i, 1].max
      per_page = [[params[:per_page].to_i, 1].max, 100].min
      per_page = 20 if per_page.zero?
      
      # Paginate the query
      paginated_services = services.page(page).per(per_page)
      
      render json: {
        services: paginated_services,
        meta: {
          current_page: paginated_services.current_page,
          next_page: paginated_services.next_page,
          prev_page: paginated_services.prev_page,
          total_pages: paginated_services.total_pages,
          total_count: paginated_services.total_count
        }
      }
    end
    
    def show
      render json: @service.as_json(methods: [:image_url])
    end
    
    def create
      @service = Service.new(service_params)
      
      if @service.save
        render json: @service, status: :created
      else
        render_error(@service.errors.full_messages, :unprocessable_entity)
      end
    end
    
    def update
      if @service.update(service_params)
        render json: @service
      else
        render_error(@service.errors.full_messages, :unprocessable_entity)
      end
    end
    
    def destroy
      # Delete image from Minio if exists
      MinioHelper.delete_object(@service.image_key) if @service.image_key.present?
      @service.destroy!
      head :no_content
    rescue => e
      render_error(@service.errors.full_messages.presence || e.message, :unprocessable_entity)
    end
    
    def add_to_draft
      request = Request.ensure_draft_for(Current.user)
      qty = params[:quantity].to_i
      qty = 1 if qty <= 0

      item = request.requests_services.find_or_initialize_by(service_id: @service.id)
      item.quantity = (item.quantity || 0) + qty
      item.position ||= request.requests_services.maximum(:position).to_i + 1

      if item.save
        render json: { request_id: request.id, items_count: request.requests_services.sum(:quantity) }
      else
        render_error(item.errors.full_messages, :unprocessable_entity)
      end
    end
    
    def image
      upload = params[:file] || params[:image]
      return render_error('No file provided', :unprocessable_entity) unless upload.is_a?(ActionDispatch::Http::UploadedFile)

      return render_error('Invalid file type. Only images are allowed.', :unprocessable_entity) unless upload.content_type.to_s.start_with?('image/')

      extension = File.extname(upload.original_filename).downcase
      filename = "#{@service.name.to_s.parameterize}-#{SecureRandom.uuid}#{extension}"

      begin
        minio_delete(@service.image_key) if @service.image_key.present?
        image_key = minio_upload(upload, key: filename, content_type: upload.content_type)

        if @service.update(image_key: image_key)
          render json: { image_url: minio_image_url(image_key), image_key: image_key }
        else
          minio_delete(image_key) rescue nil
          render_error(@service.errors.full_messages, :unprocessable_entity)
        end
      rescue => e
        Rails.logger.error("Error uploading image: #{e.message}")
        render_error('Failed to upload image', :unprocessable_entity)
      end
    end
    
    private
    
    def set_service
      @service = Service.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error('Service not found', :not_found)
    end
    
    def service_params
      params.require(:service).permit(
        :name, 
        :description, 
        :material, 
        :elasticity_gpa, 
        :inertia_cm4,
        :allowed_deflection_ratio,
        :active
      )
    end
  end
end
