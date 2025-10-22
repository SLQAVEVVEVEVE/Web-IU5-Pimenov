class Service < ApplicationRecord
  # Используем кастомное имя таблицы для соответствия предметной области
  self.table_name = "beam_types"

  # Ассоциации с заявками
  has_many :request_services,
           class_name: "RequestService",
           foreign_key: :beam_type_id,
           dependent: :restrict_with_exception
  has_many :requests,
           through: :request_services

  # Доступные материалы для балок
  MATERIALS = {
    wood: "wood",
    steel: "steel",
    reinforced_concrete: "reinforced_concrete",
    composite: "composite"
  }.freeze

  # Скоупы для фильтрации по статусу
  scope :active,   -> { all }  # Временно убираем deleted_at фильтр
  scope :deleted,  -> { none } # Временно возвращает пустой scope

  # Скоупы для фильтрации по материалу
  scope :material_wood,                -> { where(material: MATERIALS[:wood]) }
  scope :material_steel,               -> { where(material: MATERIALS[:steel]) }
  scope :material_reinforced_concrete, -> { where(material: MATERIALS[:reinforced_concrete]) }
  scope :material_composite,           -> { where(material: MATERIALS[:composite]) }

  # Валидации
  validates :name, :material, :elasticity_gpa, :norm, presence: true
  validates :material, inclusion: { in: MATERIALS.values }
  validates :elasticity_gpa,
            numericality: { greater_than: 0,
                           message: 'должно быть больше 0' }      # GPa
  validates :norm,
            numericality: { greater_than_or_equal_to: 0,
                           message: 'не может быть отрицательным' } # mm

  # Методы для проверки материала балки (например: service.material_steel?)
  MATERIALS.each do |key, val|
    define_method("material_#{key}?") { material == val }
  end

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
end
