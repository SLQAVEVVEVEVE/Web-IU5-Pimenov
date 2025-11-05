class Service < ApplicationRecord
  include ServiceScopes
  
  # Constants
  MATERIALS = %w[wooden steel reinforced_concrete].freeze
  
  # Associations
  has_many :requests_services, dependent: :destroy
  has_many :requests, through: :requests_services
  
  # Validations
  validates :name, 
            presence: true, 
            uniqueness: { case_sensitive: false }
  validates :material, 
            inclusion: { 
              in: MATERIALS, 
              message: "must be one of: #{MATERIALS.join(', ')}" 
            },
            allow_nil: true
  validates :elasticity_gpa, 
            presence: true,
            numericality: { greater_than: 0 }
  validates :inertia_cm4, 
            presence: true,
            numericality: { greater_than: 0 }
  validates :allowed_deflection_ratio, 
            numericality: { greater_than: 0 }, 
            allow_nil: true
  validates :active, 
            inclusion: { in: [true, false] }
  
  # Callbacks
  before_validation :set_default_active, on: :create
  
  # Scopes
  scope :available, -> { where(active: true) }
  # Temporary alias for backward compatibility - can be removed after updating all usages
  scope :available_scope, -> { available }
  
  # Scopes from ServiceScopes concern
  
  # Instance methods
  # Backward-compatible image handling
  def image_key
    self[:image_key] || self[:image_url]
  end
  
  # For backward compatibility with old views
  def image_url
    image_key
  end
  
  def soft_delete
    update(active: false)
  end
  
  private
  
  def set_default_active
    self.active = true if active.nil?
  end

  # --- Compatibility aliases for legacy templates ---
  def e_gpa
    # return number (GPa) or nil
    self[:elasticity_gpa]
  end

  def norm
    # return string like "L/250" if ratio present, otherwise nil
    r = self[:allowed_deflection_ratio]
    r.present? ? "L/#{r}" : nil
  end
  
  scope :active, -> { where(active: true) if column_names.include?('active') }
  
  def material_name
    material&.humanize
  end
  
  def deactivate!
    update!(active: false)
  end
  
  def activate!
    update!(active: true)
  end
end
