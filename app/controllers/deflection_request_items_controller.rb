# app/controllers/deflection_request_items_controller.rb
class DeflectionRequestItemsController < ApplicationController
  def update
    item = DeflectionRequestBeamType.find(params[:id]) # ORM
    item.update!(item_params)                          # ORM
    redirect_to deflection_request_path(item.deflection_request_id)
  end

  private

  def item_params
    params.require(:deflection_request_beam_type).permit(:quantity, :length_m, :load_kn_m)
  end
end
