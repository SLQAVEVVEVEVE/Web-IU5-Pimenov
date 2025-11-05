module RequestScopes
  extend ActiveSupport::Concern
  
  included do
    STATUSES = {
      draft:     'draft',
      formed:    'formed',
      completed: 'completed',
      rejected:  'rejected',
      deleted:   'deleted'
    }.freeze

    # Status scopes
    scope :draft,       -> { where(status: STATUSES[:draft]) }
    scope :formed,      -> { where(status: STATUSES[:formed]) }
    scope :completed,   -> { where(status: STATUSES[:completed]) }
    scope :rejected,    -> { where(status: STATUSES[:rejected]) }
    scope :active,      -> { where.not(status: STATUSES[:deleted]) }
    scope :not_deleted, -> { where.not(status: STATUSES[:deleted]) }
    scope :not_draft,   -> { where.not(status: STATUSES[:draft]) }
    scope :by_statuses, ->(statuses) { where(status: statuses) if statuses.present? }
    scope :formed_between, ->(from, to) {
      where(formed_at: from.present? && to.present? ? (from..to) : nil)
    }
    scope :draft_for, ->(user) { where(creator: user, status: STATUSES[:draft]) }
    
    # Status predicate methods
    def draft?; status == STATUSES[:draft]; end
    def formed?; status == STATUSES[:formed]; end
    def completed?; status == STATUSES[:completed]; end
    def rejected?; status == STATUSES[:rejected]; end
    def deleted?; status == STATUSES[:deleted]; end
  end
  
  # Class methods
  def self.ensure_draft_for(user)
    draft_for(user).first_or_create!
  end
  
  # Instance methods
  def can_form_by?(user)
    creator == user && draft?
  end
  
  def can_complete_by?(user)
    user.moderator? && formed?
  end
  
  def can_reject_by?(user)
    user.moderator? && formed?
  end
  
  def compute_result!
    total_deflection = 0.0
    
    requests_services.each do |rs|
      rs.deflection_mm = Calc::Deflection.call(self, rs.service)
      rs.save!
      total_deflection += rs.deflection_mm * rs.quantity
    end
    
    total_deflection
  end
  
  def calculated_items_count
    result_deflection_mm.presence || requests_services.where.not(deflection_mm: nil).count
  end
end
