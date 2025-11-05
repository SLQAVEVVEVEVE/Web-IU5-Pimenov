module Api
  module Requests
    class CartBadgeController < Api::BaseController
      def cart_badge
        draft = Request.ensure_draft_for(Current.user)
        render json: {
          request_id: draft.id,
          items_count: draft.requests_services.sum(:quantity)
        }
      end
    end
  end
end
