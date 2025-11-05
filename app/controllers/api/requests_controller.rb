module Api
  class RequestsController < BaseController
    before_action :set_request, only: [:show, :update, :form, :complete, :reject, :destroy]
    before_action :check_owner, only: [:update, :form, :destroy]
    before_action :check_moderator, only: [:complete, :reject]

    # GET /api/requests
    # List excluding draft and deleted. Filters: status (array or single), formed_at from/to.
    def index
      scope = Request.not_deleted.not_draft.includes(:creator, :moderator, :requests_services)
      statuses = Array(params[:status]).presence
      scope = scope.by_statuses(statuses) if statuses

      from = params[:from]
      to   = params[:to]
      if from.present?
        scope = scope.where('formed_at >= ?', from)
      end
      if to.present?
        scope = scope.where('formed_at <= ?', to)
      end

      scope = scope.order(formed_at: :desc)

      # simple pagination (optional)
      page = [params[:page].to_i, 1].max
      per  = [[params[:per_page].to_i, 1].max, 100].min
      per  = 20 if per.zero?
      requests = scope.page(page).per(per)

      data = requests.map do |r|
        {
          id: r.id,
          status: r.status,
          formed_at: r.formed_at,
          completed_at: r.completed_at,
          length_m: r.length_m,
          udl_kn_m: r.udl_kn_m,
          note: r.note,
          creator_login: r.creator&.email,
          moderator_login: r.moderator&.email,
          items_with_result_count: r.result_deflection_mm.present? ? nil : r.requests_services.where.not(deflection_mm: nil).count,
          result_deflection_mm: r.result_deflection_mm
        }
      end

      render json: {
        requests: data,
        meta: {
          current_page: requests.current_page,
          next_page:    requests.next_page,
          prev_page:    requests.prev_page,
          total_pages:  requests.total_pages,
          total_count:  requests.total_count
        }
      }
    end

    # GET /api/requests/:id
    def show
      render json: serialize_request(@request)
    end

    # PUT /api/requests/:id
    # Only topic fields; allow on draft (and formed if needed by LR3)
    def update
      allowed = @request.draft? || @request.formed?
      return render_error('Not authorized', :forbidden) unless allowed && @request.creator == Current.user

      if @request.update(request_params)
        render json: serialize_request(@request)
      else
        render_error(@request.errors.full_messages, :unprocessable_entity)
      end
    end

    # PUT /api/requests/:id/form
    def form
      # Ensure draft ownership for LR3
      if @request.draft? && @request.creator != Current.user
        @request.update(creator: Current.user)
      end

      return render_error('Request must be in draft status', :unprocessable_entity) unless @request.draft?
      return render_error('Not authorized', :forbidden) unless @request.creator == Current.user

      unless @request.length_m.present? && @request.udl_kn_m.present? && @request.requests_services.exists?
        return render_error('Required fields missing or empty cart', :unprocessable_entity)
      end

      @request.update!(status: RequestScopes::STATUSES[:formed], formed_at: Time.current)
      render json: serialize_request(@request)
    rescue => e
      render_error(@request.errors.full_messages.presence || e.message, :unprocessable_entity)
    end

    # PUT /api/requests/:id/complete
    def complete
      unless Current.user&.moderator?
        return render_error('Moderator access required', :forbidden)
      end
      unless @request.formed?
        return render_error('Request must be in formed status', :unprocessable_entity)
      end

      # compute results per LR rules
      total = @request.compute_result!
      ratio = @request.services.minimum(:allowed_deflection_ratio).to_f
      max_allowed = ratio.positive? ? (@request.length_m.to_f * 1000.0 / ratio) : Float::INFINITY
      within = total <= max_allowed

      @request.update!(
        status: RequestScopes::STATUSES[:completed],
        moderator: Current.user,
        completed_at: Time.current,
        result_deflection_mm: total,
        within_norm: within,
        calculated_at: Time.current
      )
      render json: serialize_request(@request)
    rescue => e
      render_error(@request.errors.full_messages.presence || e.message, :unprocessable_entity)
    end

    # PUT /api/requests/:id/reject
    def reject
      unless Current.user&.moderator?
        return render_error('Moderator access required', :forbidden)
      end
      unless @request.formed?
        return render_error('Request must be in formed status', :unprocessable_entity)
      end

      @request.update!(
        status: RequestScopes::STATUSES[:rejected],
        moderator: Current.user,
        completed_at: Time.current
      )
      render json: serialize_request(@request)
    rescue => e
      render_error(@request.errors.full_messages.presence || e.message, :unprocessable_entity)
    end

    # DELETE /api/requests/:id
    def destroy
      return render_error('Not authorized', :forbidden) unless @request.creator == Current.user
      @request.update!(status: RequestScopes::STATUSES[:deleted], completed_at: Time.current)
      head :no_content
    rescue => e
      render_error(@request.errors.full_messages.presence || e.message, :unprocessable_entity)
    end

    private

    def set_request
      @request = Request.not_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error('Request not found', :not_found)
    end

    def request_params
      params.require(:request).permit(:length_m, :udl_kn_m, :note)
    end

    def check_owner
      if @request.draft? && @request.creator != Current.user
        @request.update(creator: Current.user)
      end
      return if @request.creator == Current.user
      render_error('Not authorized', :forbidden)
    end

    def check_moderator
      return if Current.user&.moderator?
      render_error('Moderator access required', :forbidden)
    end

    def serialize_request(r)
      items = r.requests_services.includes(:service).map do |rs|
        {
          service_id: rs.service_id,
          quantity: rs.quantity,
          position: rs.position,
          deflection_mm: rs.deflection_mm,
          service: {
            id: rs.service.id,
            name: rs.service.name,
            material: rs.service.material,
            image_url: rs.service.respond_to?(:image_url) ? rs.service.image_url : rs.service.image_key
          }
        }
      end

      {
        id: r.id,
        status: r.status,
        length_m: r.length_m,
        udl_kn_m: r.udl_kn_m,
        deflection_mm: r.deflection_mm,
        within_norm: r.within_norm,
        note: r.note,
        formed_at: r.formed_at,
        completed_at: r.completed_at,
        creator_login: r.creator&.email,
        moderator_login: r.moderator&.email,
        items: items,
        result_deflection_mm: r.result_deflection_mm
      }
    end
  end
end
