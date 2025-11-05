# frozen_string_literal: true

class ServicesController < ApplicationController
  helper MinioHelper
  include MinioHelper

  # GET /services
  # Server-side search only; active services only.
  def index
    scope = Service.available

    if params[:q].present?
      q = params[:q].to_s.strip
      scope = scope.where("name ILIKE :q OR description ILIKE :q", q: "%#{q}%")
    end

    @services = scope.order(:name)

    # If ApplicationController defines current_draft (as in this project), expose a flag and count for the view.
    @cart_available = respond_to?(:current_draft, true) && current_draft.present?
    @cart_items_count = @cart_available ? current_draft.requests_services.sum(:quantity) : 0
  end

  # GET /services/:id
  def show
    @service = Service.available.find(params[:id])
  rescue ActiveRecord::RecordNotFound, ArgumentError
    redirect_to services_path, alert: "Услуга недоступна."
  end
end
