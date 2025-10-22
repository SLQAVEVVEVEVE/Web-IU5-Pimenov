class Request < ApplicationRecord
  # Используем кастомное имя таблицы для соответствия предметной области
  self.table_name = "load_forecasts"

  # Пользователь, создавший заявку (обязательная связь)
  belongs_to :requester,
             class_name: "User",
             inverse_of: :requests_requested

  # Модератор, обрабатывающий заявку (необязательная связь)
  belongs_to :moderator,
             class_name: "User",
             optional: true,
             inverse_of: :moderated_requests

  # Связанные услуги с дополнительными параметрами
  has_many :request_services,
           -> { order(:position) },
           class_name: "RequestService",
           foreign_key: :load_forecast_id,
           dependent: :destroy,
           inverse_of: :request
  has_many :services,
           through: :request_services

  # Поддержка вложенных атрибутов для связанных услуг
  accepts_nested_attributes_for :request_services,
                               allow_destroy: true

  # Возможные статусы заявки
  STATUS = {
    pending:   0,  # черновик (по умолчанию)
    formed:    1,  # сформирована (установлено formed_at)
    completed: 2,  # завершена (установлено completed_at)
    rejected:  3,  # отклонена
    deleted:   4   # удалена
  }.freeze

  # Установка статуса по умолчанию перед валидацией
  before_validation :set_default_status, on: :create

  # Игнорируемые столбцы, оставленные для обратной совместимости
  self.ignored_columns = %w[length_m load_kN_m result_mm engineer_id]

  # Скоупы для выборки записей
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: STATUS[:deleted]) }
  scope :by_status, ->(s) {
    return if s.blank?
    val = s.is_a?(Integer) ? s : STATUS[s.to_sym]
    where(status: val) if val
  }

  # Валидации
  validates :status, inclusion: {
    in: STATUS.values,
    message: 'имеет недопустимое значение'
  }
  validates :requester_id, presence: {
    message: 'не может быть пустым'
  }

  # Проверка дат в зависимости от статуса
  validate :validate_dates_by_status

  # Скоупы и методы для работы со статусами
  # Например: Request.pending, some_request.pending?
  STATUS.each do |name, value|
    scope name, -> { where(status: value) }
    define_method("#{name}?") { status == value }
  end

  private

  # Установка статуса по умолчанию
  def set_default_status
    self.status = STATUS[:pending] if status.nil?
  end

  # Валидация дат в зависимости от статуса
  def validate_dates_by_status
    if formed? && formed_at.nil?
      errors.add(:formed_at, 'должна быть указана для сформированной заявки')
    end

    if completed? && completed_at.nil?
      errors.add(:completed_at, 'должна быть указана для завершенной заявки')
    end
  end

  class << self
    # Преобразование статуса в числовое значение
    # @param val [Integer, String, Symbol, nil] значение для преобразования
    # @return [Integer] числовое значение статуса
    def coerce_status(val)
      return STATUS[:pending] if val.nil?

      case val
      when Integer
        STATUS.values.include?(val) ? val : STATUS[:pending]
      when String, Symbol
        key = val.to_s.strip.downcase.to_sym
        STATUS[key] || STATUS[:pending]
      else
        STATUS[:pending]
      end
    end
  end

  # Любые присваивания status будут проходить через коэрцию
  def status=(val)
    super(self.class.coerce_status(val))
  end
end
