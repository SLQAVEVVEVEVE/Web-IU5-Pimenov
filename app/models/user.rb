class User < ApplicationRecord
  has_secure_password

  # Заявки, созданные пользователем
  has_many :requests_requested,
           class_name: "Request",
           foreign_key: :requester_id,
           inverse_of: :requester,
           dependent: :nullify

  # Заявки, которые пользователь модерирует
  has_many :moderated_requests,
           class_name: "Request",
           foreign_key: :moderator_id,
           inverse_of: :moderator,
           dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :is_moderator, inclusion: { in: [true, false] }
end
