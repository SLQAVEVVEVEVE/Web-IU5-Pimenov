class RequestsService < ApplicationRecord
  belongs_to :request
  belongs_to :service

  # Set default values
  attribute :is_primary, :boolean, default: false
  attribute :quantity, :integer, default: 1
  attribute :position, :integer, default: 1

  # Validations
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :is_primary, inclusion: { in: [true, false] }
  validates :request_id, uniqueness: { scope: :service_id }
  
  # Backward compatibility
  before_validation do
    self.is_primary = false if is_primary.nil?
    self.quantity = 1 if quantity.nil?
    self.position = 1 if position.nil?
  end
end
