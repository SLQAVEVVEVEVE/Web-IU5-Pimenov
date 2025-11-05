class Request < ApplicationRecord
  include RequestScopes
  
  # Constants moved to RequestScopes
  STATUSES = RequestScopes::STATUSES
  
  # Associations
  belongs_to :creator, 
             class_name: 'User', 
             foreign_key: :creator_id, 
             inverse_of: :requests
             
  belongs_to :moderator, 
             class_name: 'User', 
             foreign_key: :moderator_id, 
             optional: true, 
             inverse_of: :moderated_requests
  
  has_many :requests_services, dependent: :destroy
  has_many :services, through: :requests_services
  
  # Validations
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :creator_id, presence: true
  validates :length_m, :udl_kn_m, numericality: { greater_than: 0 }, allow_nil: true
  
  # Callbacks
  before_validation :set_default_status, on: :create
  
  # Status predicate methods are now in RequestScopes
  
  # Scopes are now in RequestScopes
  
  # Class methods
  def self.ensure_draft_for(user)
    draft_for(user).first_or_create! do |request|
      request.creator = user
    end
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
    
    update!(result_deflection_mm: total_deflection)
    total_deflection
  end
  
  def calculated_items_count
    result_deflection_mm.presence || requests_services.where.not(deflection_mm: nil).count
  end
  
  private
  
  def set_default_status
    self.status ||= STATUSES[:draft]
  end
  validates :length_m, numericality: { greater_than: 0 }, allow_nil: true
  validates :udl_kn_m, numericality: { greater_than: 0 }, allow_nil: true
  validates :deflection_mm,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  
  # One draft per user
  validate :validate_single_draft_per_user, if: :draft?
  
  scope :draft, -> { where(status: STATUSES[:draft]) }
  scope :active, -> { where.not(status: [STATUSES[:deleted], STATUSES[:rejected]]) }
  scope :completed, -> { where(status: STATUSES[:completed]) }
  
  before_save :set_timestamps
  
  def draft? = status == STATUSES[:draft]
  def deleted? = status == STATUSES[:deleted]
  def formed? = status == STATUSES[:formed]
  def completed? = status == STATUSES[:completed]
  def rejected? = status == STATUSES[:rejected]
  public :draft?, :deleted?, :formed?, :completed?, :rejected?
  
  def mark_as_formed!(moderator: nil)
    update!(
      status: STATUSES[:formed],
      moderator: moderator,
      formed_at: Time.current
    )
  end
  
  # Calculate deflection for a single request service (in mm)
  def self.deflection_mm_for(rs)
    l = rs.length_m.to_f                  # m
    q = rs.udl_kn_m.to_f * 1000.0         # kN/m -> N/m
    e = rs.service.elasticity_gpa.to_f * 1e9      # ГПа -> Па
    j = rs.service.inertia_cm4.to_f * 1e-8        # см^4 -> м^4
    return 0.0 if l <= 0 || q <= 0 || e <= 0 || j <= 0

    w_m = 5.0 * q * (l ** 4) / (384.0 * e * j)    # in meters
    w_m * 1000.0                                   # -> mm
  end

  # Calculate and store deflections for all services in the request
  def compute_and_store_result_deflection!
    total = 0.0
    requests_services.find_each do |rs|
      w_mm = self.class.deflection_mm_for(rs)
      rs.update_column(:deflection_mm, w_mm) # update without validations
      total += w_mm
    end
    update_columns(
      result_deflection_mm: total,
      calculated_at: Time.current
    )
  end

  def complete!(deflection_mm: nil, within_norm: nil)
    update!(
      status: STATUSES[:completed],
      completed_at: Time.current,
      result_deflection_mm: deflection_mm,
      within_norm: within_norm
    )
    compute_and_store_result_deflection! if deflection_mm.nil?
  end
  
  def reject!(moderator:)
    update!(
      status: STATUSES[:rejected],
      moderator: moderator
    )
  end
  
  def soft_delete!
    update!(status: STATUSES[:deleted])
  end
  
  private
  
  def validate_single_draft_per_user
    return unless creator_id.present?
    exists = self.class.where(creator_id: creator_id, status: STATUSES[:draft])
    exists = exists.where.not(id: id) if persisted?
    errors.add(:base, 'У пользователя уже есть черновик') if exists.exists?
  end
  
  def set_timestamps
    return unless status_changed?
    
    case status
    when STATUSES[:formed]
      self.formed_at ||= Time.current
    when STATUSES[:completed]
      self.completed_at ||= Time.current
    end
  end
end
