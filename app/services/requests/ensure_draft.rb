module Requests
  class EnsureDraft
    def initialize(user_id:)
      @user_id = user_id
    end

    def call
      Request
        .where(requester_id: @user_id, status: Request::STATUS[:pending])
        .order(id: :desc)
        .first || create_draft!
    end

    private

    def create_draft!
      Request.create!(
        requester_id: @user_id,
        status: Request::STATUS[:pending],
        formed_at: nil,
        completed_at: nil,
        moderator_id: nil
      )
    end
  end
end
