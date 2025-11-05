class RequestStateMachine
  TRANSITIONS = {
    draft: [:formed, :deleted],
    formed: [:completed, :rejected]
  }.freeze

  def initialize(request, user)
    @request = request
    @user = user
  end

  def can_transition_to?(new_status)
    return false unless @request.status
    return true if new_status.to_s == @request.status # Allow same state

    TRANSITIONS.dig(@request.status.to_sym, new_status.to_sym).present? &&
      valid_actor?(new_status)
  end

  def transition_to(new_status, attributes = {})
    new_status = new_status.to_s
    return false unless can_transition_to?(new_status)

    @request.transaction do
      case new_status
      when 'formed'
        @request.formed_at = Time.current
      when 'completed', 'rejected'
        @request.completed_at = Time.current
        @request.moderator = @user
      end

      @request.status = new_status
      @request.assign_attributes(attributes)
      @request.save!
    end

    true
  rescue => e
    @request.errors.add(:base, "State transition failed: #{e.message}")
    false
  end

  private

  def valid_actor?(new_status)
    case new_status.to_s
    when 'formed', 'deleted'
      @user == @request.creator
    when 'completed', 'rejected'
      @user.moderator?
    else
      false
    end
  end
end
