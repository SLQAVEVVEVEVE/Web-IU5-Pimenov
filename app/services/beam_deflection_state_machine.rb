class BeamDeflectionStateMachine
  TRANSITIONS = {
    draft: [:formed, :deleted],
    formed: [:completed, :rejected]
  }.freeze

  def initialize(beam_deflection, user)
    @beam_deflection = beam_deflection
    @user = user
  end

  def can_transition_to?(new_status)
    return false unless @beam_deflection.status
    return true if new_status.to_s == @beam_deflection.status # Allow same state

    TRANSITIONS.dig(@beam_deflection.status.to_sym, new_status.to_sym).present? &&
      valid_actor?(new_status)
  end

  def transition_to(new_status, attributes = {})
    new_status = new_status.to_s
    return false unless can_transition_to?(new_status)

    @beam_deflection.transaction do
      case new_status
      when 'formed'
        @beam_deflection.formed_at = Time.current
      when 'completed', 'rejected'
        @beam_deflection.completed_at = Time.current
        @beam_deflection.moderator = @user
      end

      @beam_deflection.status = new_status
      @beam_deflection.assign_attributes(attributes)
      @beam_deflection.save!
    end

    true
  rescue => e
    @beam_deflection.errors.add(:base, "State transition failed: #{e.message}")
    false
  end

  private

  def valid_actor?(new_status)
    case new_status.to_s
    when 'formed', 'deleted'
      @user == @beam_deflection.creator
    when 'completed', 'rejected'
      @user.moderator?
    else
      false
    end
  end
end
