class BeamType < ApplicationRecord
  has_many :items,
           class_name: "DeflectionRequestBeamType",
           dependent: :restrict_with_error
end