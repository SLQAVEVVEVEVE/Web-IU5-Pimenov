class User < ApplicationRecord
  has_secure_password
  has_many :deflection_requests, foreign_key: :requester_id
end
