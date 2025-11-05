class Service < ApplicationRecord
  MATERIALS = %w[wooden steel reinforced_concrete].freeze
  
  has_many :requests_services, dependent: :restrict_with_error
  has_many :requests, through: :requests_services

  # Return only available services. If there is no `active` column, fall back to all.
  scope :available, -> {
    column_names.include?('active') ? where(active: true) : all
  }

  # Backward-compat alias used by some controllers
  def self.available_scope
    available
  end
  
  validates :name, 
            presence: true, 
            uniqueness: { case_sensitive: false }
  validates :material, 
            presence: true,
            inclusion: { in: MATERIALS, message: "must be one of: #{MATERIALS.join(', ')}" }
  validates :elasticity_gpa, 
            presence: true,
            numericality: { greater_than: 0 }
  validates :inertia_cm4, 
            presence: true,
            numericality: { greater_than: 0 }
  validates :allowed_deflection_ratio, 
            numericality: { greater_than: 0 }, 
            allow_nil: true

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
