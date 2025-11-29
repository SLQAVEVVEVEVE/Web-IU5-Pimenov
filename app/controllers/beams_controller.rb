# frozen_string_literal: true

class BeamsController < ApplicationController
  helper MinioHelper
  include MinioHelper

  # GET /beams
  # Server-side search only; active beams only.
  def index
    scope = Beam.available

    if params[:q].present?
      q = params[:q].to_s.strip
      scope = scope.where("name ILIKE :q OR description ILIKE :q", q: "%#{q}%")
    end

    @beams = scope.order(:name)

    # If ApplicationController defines current_draft (as in this project), expose a flag and count for the view.
    @cart_available = respond_to?(:current_draft, true) && current_draft.present?
    @cart_items_count = @cart_available ? current_draft.beam_deflection_beams.sum(:quantity) : 0
  end

  # GET /beams/:id
  def show
    @beam = Beam.available.find(params[:id])
  rescue ActiveRecord::RecordNotFound, ArgumentError
    redirect_to beams_path, alert: "Балка недоступна."
  end
end
