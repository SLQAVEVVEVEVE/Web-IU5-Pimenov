class DeflectionRequest < ApplicationRecord
  # Коды статусов
  STATUS_DRAFT     = 0
  STATUS_FORMED    = 1
  STATUS_COMPLETED = 2
  STATUS_REJECTED  = 3
  STATUS_DELETED   = 4

  # Скоупы
  scope :draft,     -> { where(status: STATUS_DRAFT) }
  scope :formed,    -> { where(status: STATUS_FORMED) }
  scope :completed, -> { where(status: STATUS_COMPLETED) }
  scope :rejected,  -> { where(status: STATUS_REJECTED) }
  scope :alive,     -> { where.not(status: STATUS_DELETED) }

  belongs_to :requester, class_name: "User"

  has_many :items,
           class_name: "DeflectionRequestBeamType",
           dependent: :destroy,
           inverse_of: :deflection_request

  validates :requester_id, presence: true
  validates :status, inclusion: { in: [STATUS_DRAFT, STATUS_FORMED, STATUS_COMPLETED, STATUS_REJECTED, STATUS_DELETED] }

  # Предикаты (удобно для вьюх/контроллера)
  def draft?     = status == STATUS_DRAFT
  def formed?    = status == STATUS_FORMED
  def completed? = status == STATUS_COMPLETED
  def rejected?  = status == STATUS_REJECTED
  def deleted?   = status == STATUS_DELETED

  # Читаемое имя статуса (для отображения)
  def status_name
    {
      STATUS_DRAFT     => "черновик",
      STATUS_FORMED    => "сформирована",
      STATUS_COMPLETED => "завершена",
      STATUS_REJECTED  => "отклонена",
      STATUS_DELETED   => "удалена"
    }[status] || "неизвестно"
  end
end
