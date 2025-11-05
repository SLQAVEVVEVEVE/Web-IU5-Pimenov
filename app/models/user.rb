class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :requests, 
           class_name: "Request", 
           foreign_key: :creator_id, 
           inverse_of: :creator, 
           dependent: :nullify
           
  has_many :moderated_requests, 
           class_name: "Request", 
           foreign_key: :moderator_id, 
           inverse_of: :moderator, 
           dependent: :nullify

  # Validations
  validates :email, 
            presence: true, 
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :password_confirmation, presence: true, on: :create
  
  # Class methods
  def self.demo_user
    find_or_create_by!(email: "demo@local") do |u|
      u.password = SecureRandom.hex(8)
      u.moderator = false
    end
  end

  # LR3: consider demo user as moderator to simplify testing moderator-only actions
  def moderator?
    self[:moderator] || email == 'demo@local'
  end
end