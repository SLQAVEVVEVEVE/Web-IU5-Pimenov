class CartItemsController < ApplicationController
  before_action :require_user

  def create
    beam = Beam.available.find_by(id: params[:beam_id])
    return redirect_back fallback_location: beams_path, alert: "Балка недоступна." unless beam

    BeamDeflectionBeam.transaction do
      draft = BeamDeflection.find_by(creator_id: current_user.id, status: "draft") ||
              BeamDeflection.create!(creator_id: current_user.id, status: "draft")
      
      bdb = BeamDeflectionBeam.lock.find_by(beam_deflection_id: draft.id, beam_id: beam.id)
      qty = (params[:quantity].presence || 1).to_i
      
      if bdb
        bdb.update!(quantity: bdb.quantity + qty)
      else
        BeamDeflectionBeam.create!(
          beam_deflection_id: draft.id,
          beam_id: beam.id,
          quantity: qty,
          position: (params[:position].presence || 1).to_i,
          is_primary: false  # Always set to false for new items
        )
      end
    end

    redirect_to cart_path, notice: "Балка добавлена в заявку."
  end

  private
  
  def require_user
    current_user || head(:unauthorized)
  end
end
