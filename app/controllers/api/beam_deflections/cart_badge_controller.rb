module Api
  module BeamDeflections
    class CartBadgeController < Api::BaseController
      def cart_badge
        draft = BeamDeflection.ensure_draft_for(Current.user)
        render json: {
          beam_deflection_id: draft.id,
          items_count: draft.beam_deflection_beams.sum(:quantity)
        }
      end
    end
  end
end
