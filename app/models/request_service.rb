# Связующая модель между Request и Service
# Содержит дополнительные параметры для расчета прогиба
class RequestService < ApplicationRecord
  # Используем кастомное имя таблицы для соответствия соглашениям
  self.table_name = "load_forecasts_beam_types"
  default_scope { where(deleted_at: nil) }

  # Метод для "мягкого" удаления
  def soft_delete
    update_column(:deleted_at, Time.current)
  end

  # Метод для восстановления
  def restore
    update_column(:deleted_at, nil)
  end

  # Проверка, удалена ли запись
  def deleted?
    deleted_at.present?
  end

  # Связь с родительской заявкой
  belongs_to :request,
             foreign_key: :load_forecast_id,
             inverse_of: :request_services

  # Связь с услугой
  belongs_to :service,
             foreign_key: :beam_type_id

  # Валидации
  validates :quantity,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: 'должно быть целым числом больше 0'
            }

  validates :position,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: 'должно быть положительным числом'
            }

  validates :length_m, :load_kn_m,
            presence: {
              message: 'не может быть пустым'
            },
            numericality: {
              greater_than: 0,
              message: 'должно быть больше 0'
            }

  # Уникальность комбинации параметров в рамках одной заявки
  validates :beam_type_id,
            uniqueness: {
              scope: [:load_forecast_id, :length_m, :load_kn_m],
              message: 'комбинация уже есть в этой заявке'
            }

  # Автоматическое назначение позиции при создании
  before_validation :assign_position, on: :create

  private

  # Назначение следующей доступной позиции
  # @return [Integer] следующая позиция в списке
  def assign_position
    return if position.present? && position.positive?

    max_position = request&.request_services&.maximum(:position) || 0
    self.position = max_position + 1
  end
end


