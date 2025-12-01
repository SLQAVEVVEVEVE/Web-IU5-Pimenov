# 🧪 Руководство по тестированию API

## 📋 Содержание

1. [Импорт коллекции в Insomnia](#импорт-коллекции-в-insomnia)
2. [Модели и сериализаторы](#модели-и-сериализаторы)
3. [Функция-singleton](#функция-singleton)
4. [Порядок выполнения тестов](#порядок-выполнения-тестов)
5. [SQL запросы для проверки](#sql-запросы-для-проверки)

---

## 📥 Импорт коллекции в Insomnia

### Шаг 1: Импорт файла
1. Откройте Insomnia
2. Меню → **Import/Export** → **Import Data** → **From File**
3. Выберите файл `Insomnia_Collection_DEMO.json`
4. Подтвердите импорт

### Шаг 2: Настройка переменных окружения
После импорта откройте **Environment** и заполните переменные:

```json
{
  "base_url": "http://localhost:3000",
  "user_token": "",       // Заполнится после запроса #17
  "moderator_token": "",  // Заполнится после запроса #18
  "new_beam_id": "",      // Заполнится после запроса #5
  "draft_id": "",         // Заполнится после запроса #9
  "formed_id": "",        // Используется в примерах (опционально)
  "new_user_token": ""    // Заполнится после запроса #16
}
```

---

## 🏗️ Модели и сериализаторы

### Модели

#### 1. User (`app/models/user.rb`)
**Файл:** `app/models/user.rb`

```ruby
class User < ApplicationRecord
  has_secure_password

  # Ассоциации
  has_many :beam_deflections, foreign_key: :creator_id, dependent: :destroy
  has_many :moderated_beam_deflections, class_name: 'BeamDeflection', foreign_key: :moderator_id

  # Валидации
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  # Методы
  def moderator?
    moderator
  end
end
```

**Поля:**
- `id` - PRIMARY KEY
- `email` - string, unique
- `password_digest` - string (bcrypt hash)
- `moderator` - boolean (default: false)

---

#### 2. Beam (`app/models/beam.rb`)
**Файл:** `app/models/beam.rb`

```ruby
class Beam < ApplicationRecord
  include BeamScopes

  # Ассоциации
  has_many :beam_deflection_beams, dependent: :destroy
  has_many :beam_deflections, through: :beam_deflection_beams

  # Валидации
  validates :name, presence: true
  validates :material, inclusion: { in: %w[wooden steel reinforced_concrete] }
  validates :elasticity_gpa, numericality: { greater_than: 0 }
  validates :inertia_cm4, numericality: { greater_than: 0 }
  validates :allowed_deflection_ratio, numericality: { greater_than: 0 }

  # Методы
  def image_url
    return MinioHelper.minio_image_url(image_key) if image_key.present?
    # Fallback SVG placeholder
  end
end
```

**Поля:**
- `id` - PRIMARY KEY
- `name` - string (название балки)
- `description` - text
- `material` - string (wooden/steel/reinforced_concrete)
- `elasticity_gpa` - decimal (модуль упругости, ГПа)
- `inertia_cm4` - decimal (момент инерции, см⁴)
- `allowed_deflection_ratio` - decimal (допустимое соотношение прогиба)
- `image_key` - string (ключ изображения в MinIO)
- `active` - boolean (soft delete)

---

#### 3. BeamDeflection (`app/models/beam_deflection.rb`)
**Файл:** `app/models/beam_deflection.rb`

```ruby
class BeamDeflection < ApplicationRecord
  include BeamDeflectionScopes

  # Ассоциации
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  belongs_to :moderator, class_name: 'User', foreign_key: :moderator_id, optional: true
  has_many :beam_deflection_beams, dependent: :destroy
  has_many :beams, through: :beam_deflection_beams

  # Валидации
  validates :status, presence: true
  validates :length_m, numericality: { greater_than: 0 }, allow_nil: true
  validates :udl_kn_m, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Singleton для создания draft заявки
  def self.ensure_draft_for(user)
    draft_for(user).first_or_create! do |request|
      request.creator = user
    end
  end

  # Расчет прогиба
  def compute_result!
    total_deflection = 0.0
    beam_deflection_beams.each do |bdb|
      bdb.deflection_mm = Calc::Deflection.call(self, bdb.beam)
      bdb.save!
      total_deflection += bdb.deflection_mm * bdb.quantity
    end
    update!(result_deflection_mm: total_deflection)
    total_deflection
  end
end
```

**Поля:**
- `id` - PRIMARY KEY
- `creator_id` - foreign key → users
- `moderator_id` - foreign key → users (nullable)
- `status` - string (draft/formed/completed/rejected/deleted)
- `length_m` - decimal (длина пролета, метры)
- `udl_kn_m` - decimal (равномерная нагрузка, кН/м)
- `note` - text
- `result_deflection_mm` - decimal (результат расчета, мм)
- `within_norm` - boolean (в пределах нормы)
- `formed_at` - datetime (дата формирования)
- `completed_at` - datetime (дата завершения)
- `calculated_at` - datetime (дата расчета)

---

#### 4. BeamDeflectionBeam (м-м)
**Файл:** `app/models/beam_deflection_beam.rb`

```ruby
class BeamDeflectionBeam < ApplicationRecord
  # Ассоциации
  belongs_to :beam_deflection
  belongs_to :beam

  # Валидации
  validates :quantity, numericality: { greater_than: 0 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :beam_id, uniqueness: { scope: :beam_deflection_id }
end
```

**Поля:**
- `id` - PRIMARY KEY
- `beam_deflection_id` - foreign key → beam_deflections
- `beam_id` - foreign key → beams
- `quantity` - integer (количество)
- `position` - integer (порядковый номер)
- `is_primary` - boolean
- `deflection_mm` - decimal (расчетный прогиб для этой балки, мм)

---

### Сериализаторы

В Rails API используется **ручная сериализация** через методы контроллера, а не Active Model Serializers.

#### Пример: BeamDeflection serializer
**Файл:** `app/controllers/api/beam_deflections_controller.rb:183-212`

```ruby
def serialize_beam_deflection(bd)
  items = bd.beam_deflection_beams.includes(:beam).map do |bdb|
    beam = bdb.beam
    {
      beam_id: bdb.beam_id,
      beam_name: beam&.name,
      beam_material: beam&.material,
      beam_image_url: beam&.respond_to?(:image_url) ? beam&.image_url : beam&.try(:image_key),
      quantity: bdb.quantity,
      position: bdb.position,
      deflection_mm: bdb.deflection_mm
    }
  end

  {
    id: bd.id,
    status: bd.status,
    length_m: bd.length_m,
    udl_kn_m: bd.udl_kn_m,
    deflection_mm: bd.deflection_mm,
    within_norm: bd.within_norm,
    note: bd.note,
    formed_at: bd.formed_at,
    completed_at: bd.completed_at,
    creator_login: bd.creator&.email,
    moderator_login: bd.moderator&.email,
    items: items,
    result_deflection_mm: bd.result_deflection_mm
  }
end
```

**Особенности:**
- ✅ Включает связанные данные (items с beams)
- ✅ Логины через email (creator_login, moderator_login)
- ✅ Image URL через MinIO helper
- ✅ Вычисляемые поля (deflection_mm для каждой балки)

#### Пример: Beam serializer
**Файл:** `app/controllers/api/beams_controller.rb:36`

```ruby
def show
  render json: @beam.as_json(methods: [:image_url])
end
```

Используется стандартный `as_json` с добавлением вычисляемого метода `image_url`.

---

## 🔄 Функция-singleton

### `ensure_draft_for(user)`

**Файл:** `app/models/beam_deflection.rb:35-39`

```ruby
def self.ensure_draft_for(user)
  draft_for(user).first_or_create! do |request|
    request.creator = user
  end
end
```

**Использование в контроллерах:**

#### 1. BeamsController#add_to_draft
**Файл:** `app/controllers/api/beams_controller.rb:66-80`

```ruby
def add_to_draft
  beam_deflection = BeamDeflection.ensure_draft_for(Current.user)
  qty = params[:quantity].to_i
  qty = 1 if qty <= 0

  item = beam_deflection.beam_deflection_beams.find_or_initialize_by(beam_id: @beam.id)
  item.quantity = (item.quantity || 0) + qty
  item.position ||= beam_deflection.beam_deflection_beams.maximum(:position).to_i + 1

  if item.save
    render json: { beam_deflection_id: beam_deflection.id, items_count: beam_deflection.beam_deflection_beams.sum(:quantity) }
  else
    render_error(item.errors.full_messages, :unprocessable_entity)
  end
end
```

#### 2. CartBadgeController#cart_badge
**Файл:** `app/controllers/api/beam_deflections/cart_badge_controller.rb:4-10`

```ruby
def cart_badge
  draft = BeamDeflection.ensure_draft_for(Current.user)
  render json: {
    beam_deflection_id: draft.id,
    items_count: draft.beam_deflection_beams.sum(:quantity)
  }
end
```

**Принцип работы:**
1. ✅ **Singleton Pattern** - для каждого пользователя существует только ОДНА draft заявка
2. ✅ **Автоматическое создание** - если draft нет, создается автоматически
3. ✅ **Константа статуса** - используется `STATUSES[:draft]` из concern
4. ✅ **Использование в методах** - add_to_draft, cart_badge

**Scope `draft_for`:**
```ruby
scope :draft_for, ->(user) { where(creator: user, status: STATUSES[:draft]) }
```

---

## 🎯 Порядок выполнения тестов

### Подготовка (выполнить один раз)

#### 1. Запустить сервисы
```bash
docker-compose up
```

#### 2. Создать демо-пользователей (если еще не созданы)
```bash
docker-compose exec web bin/rails runner prepare_demo.rb
```

---

### Тестирование (по порядку показа)

| № | Запрос | Что проверяется | Действие после |
|---|--------|-----------------|----------------|
| **17** | POST Sign In (User) | Аутентификация пользователя | ✏️ Скопировать `token` → `user_token` |
| **18** | POST Sign In (Moderator) | Аутентификация модератора | ✏️ Скопировать `token` → `moderator_token` |
| **01** | GET Список заявок (фильтр) | Фильтрация по дате и статусу | Увидеть completed заявки |
| **02** | GET Иконки корзины | Singleton draft заявки | Запомнить `beam_deflection_id` |
| **03** | DELETE Заявку | Удаление draft (если есть) | ✏️ Обновить `draft_id` если нужно |
| **04** | GET Список услуг (фильтр) | Фильтрация по active, search | Выбрать ID балок |
| **05** | POST Новая услуга | Создание без изображения | ✏️ Скопировать `id` → `new_beam_id` |
| **06** | POST Добавить изображение | MinIO, латиница в названии | Проверить `image_url` |
| **07** | POST Добавить услугу #1 | Добавление в draft (ID=39) | Запомнить `items_count` |
| **08** | POST Добавить услугу #2 | Добавление в draft (ID=40) | Запомнить новый `items_count` |
| **09** | GET Иконки корзины | Проверка количества (5 услуг) | ✏️ Скопировать `beam_deflection_id` → `draft_id` |
| **10** | GET Заявку | Просмотр заявки с 2 услугами | Увидеть items с изображениями |
| **11** | PUT Изменить м-м | Изменение quantity/position без PK | Проверить изменения |
| **12** | PUT Изменить заявку | Изменение length_m, udl_kn_m | Проверить обновление |
| **13** | PUT Завершить заявку | ❌ ОШИБКА (draft status) | Увидеть 422 ошибку |
| **14** | PUT Сформировать заявку | Проверка обязательных полей | Увидеть `formed_at` |
| **15** | PUT Завершить заявку | ✅ Расчет прогиба по формуле | Увидеть `result_deflection_mm` |
| **16** | POST Регистрация | Создание нового пользователя | ✏️ Скопировать `token` |
| **19** | GET Текущий пользователь | Данные личного кабинета | Увидеть email, moderator |
| **20** | PUT Обновить пользователя | Изменение email/password | Проверить обновление |
| **21** | POST Деавторизация | JWT blacklist в Redis | Token станет невалидным |

---

## 🔍 SQL запросы для проверки

После выполнения тестов можно проверить данные через Rails console:

```bash
docker-compose exec web bin/rails console
```

### 1. Проверить созданную услугу
```ruby
# Найти последнюю созданную балку
beam = Beam.last
puts "Name: #{beam.name}"
puts "Image Key: #{beam.image_key}"
puts "Image URL: #{beam.image_url}"
```

### 2. Проверить заявку с расчетом
```ruby
# Найти последнюю completed заявку
bd = BeamDeflection.completed.last

puts "Status: #{bd.status}"
puts "Creator: #{bd.creator.email}"
puts "Moderator: #{bd.moderator.email}"
puts "Length: #{bd.length_m} m"
puts "UDL: #{bd.udl_kn_m} kN/m"
puts "Result Deflection: #{bd.result_deflection_mm} mm"
puts "Within Norm: #{bd.within_norm}"

# Просмотр items
bd.beam_deflection_beams.each do |item|
  puts "  - #{item.beam.name} x#{item.quantity}: #{item.deflection_mm} mm"
end
```

### 3. Проверить singleton draft
```ruby
user = User.find_by(email: 'user@demo.com')

# Найти draft
draft = BeamDeflection.draft_for(user).first
puts "Draft ID: #{draft.id}"
puts "Items count: #{draft.beam_deflection_beams.count}"

# Проверить singleton (должен вернуть тот же объект)
draft2 = BeamDeflection.ensure_draft_for(user)
puts "Same object? #{draft.id == draft2.id}" # => true
```

### 4. Проверить формулу расчета
```ruby
# Вручную рассчитать прогиб для одной балки
bd = BeamDeflection.last
beam = Beam.find(39)

q = bd.udl_kn_m * 1000  # кН/м -> Н/м
l = bd.length_m
e = beam.elasticity_gpa * 1e9  # ГПа -> Па
j = beam.inertia_cm4 * 1e-8  # см⁴ -> м⁴

deflection = (5 * q * (l ** 4)) / (384 * e * j) * 1000  # в мм

puts "Calculated: #{deflection} mm"
puts "Stored: #{bd.beam_deflection_beams.find_by(beam_id: 39).deflection_mm} mm"
```

### 5. Проверить Redis blacklist
```bash
docker-compose exec redis redis-cli
```

```redis
# Посмотреть все blacklist ключи
KEYS "jwt:blacklist:*"

# Проверить TTL ключа
TTL "jwt:blacklist:<hash>"

# Посмотреть значение
GET "jwt:blacklist:<hash>"
```

### 6. Проверить MinIO
```bash
# Web UI: http://localhost:9001
# Login: minioadmin / minioadmin

# Или через CLI
docker-compose exec minio mc ls minio/beam-deflection
```

---

## 📊 Ожидаемые результаты

### После выполнения всех тестов:

**Users:**
- ✅ user@demo.com (ID: 39)
- ✅ moderator@demo.com (ID: 40)
- ✅ newuser@test.com (новый)

**Beams:**
- ✅ 9 существующих балок
- ✅ 1 новая "Test Beam Demo" с изображением

**BeamDeflections:**
- ✅ 1 completed заявка с расчетом прогиба
- ✅ 1 draft заявка (если не удалили)

**Redis:**
- ✅ 1+ blacklist ключей

**MinIO:**
- ✅ Изображение новой балки в bucket

---

## 🎓 Объяснение для демонстрации

### Модели
1. **User** - аутентификация через bcrypt, роли (moderator)
2. **Beam** - услуги с материалами и физическими свойствами
3. **BeamDeflection** - заявки с state machine
4. **BeamDeflectionBeam** - м-м с дополнительными полями (quantity, position, deflection_mm)

### Сериализаторы
- Ручная сериализация через методы контроллера
- Включение связанных данных (eager loading)
- Логины через email вместо ID
- Вычисляемые поля (image_url, items_with_result_count)

### Функция-singleton
- **`ensure_draft_for(user)`** - гарантирует единственную draft заявку для пользователя
- Используется в `add_to_draft` и `cart_badge`
- Автоматическое создание при отсутствии

### Формула расчета
```
w = 5 * q * L⁴ / (384 * E * J)

где:
  q - нагрузка (Н/м)
  L - длина пролета (м)
  E - модуль упругости (Па)
  J - момент инерции (м⁴)
  w - прогиб (м) → * 1000 = мм
```

---

**Готово к демонстрации!** 🚀
