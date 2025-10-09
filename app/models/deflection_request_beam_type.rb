class DeflectionRequestBeamType < ApplicationRecord
  belongs_to :deflection_request
  belongs_to :beam_type

  validates :beam_type_id,
            uniqueness: { scope: :deflection_request_id,
                          message: "эта балка уже есть в заявке" }

  # по умолчанию
  attribute :quantity, :integer, default: 1
  attribute :length_m, :decimal, default: 3.0
  attribute :load_kn_m, :decimal, default: 10.0

  # валидации
  validates :quantity, numericality: { greater_than: 0 }
  validates :length_m, numericality: { greater_than: 0 }, allow_nil: true
  validates :load_kn_m, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end