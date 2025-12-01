# рџ§Є Р СѓРєРѕРІРѕРґСЃС‚РІРѕ РїРѕ С‚РµСЃС‚РёСЂРѕРІР°РЅРёСЋ API

## рџ“‹ РЎРѕРґРµСЂР¶Р°РЅРёРµ

1. [РРјРїРѕСЂС‚ РєРѕР»Р»РµРєС†РёРё РІ Insomnia](#РёРјРїРѕСЂС‚-РєРѕР»Р»РµРєС†РёРё-РІ-insomnia)
2. [РњРѕРґРµР»Рё Рё СЃРµСЂРёР°Р»РёР·Р°С‚РѕСЂС‹](#РјРѕРґРµР»Рё-Рё-СЃРµСЂРёР°Р»РёР·Р°С‚РѕСЂС‹)
3. [Р¤СѓРЅРєС†РёСЏ-singleton](#С„СѓРЅРєС†РёСЏ-singleton)
4. [РџРѕСЂСЏРґРѕРє РІС‹РїРѕР»РЅРµРЅРёСЏ С‚РµСЃС‚РѕРІ](#РїРѕСЂСЏРґРѕРє-РІС‹РїРѕР»РЅРµРЅРёСЏ-С‚РµСЃС‚РѕРІ)
5. [SQL Р·Р°РїСЂРѕСЃС‹ РґР»СЏ РїСЂРѕРІРµСЂРєРё](#sql-Р·Р°РїСЂРѕСЃС‹-РґР»СЏ-РїСЂРѕРІРµСЂРєРё)

---

## рџ“Ґ РРјРїРѕСЂС‚ РєРѕР»Р»РµРєС†РёРё РІ Insomnia

### РЁР°Рі 1: РРјРїРѕСЂС‚ С„Р°Р№Р»Р°
1. РћС‚РєСЂРѕР№С‚Рµ Insomnia
2. РњРµРЅСЋ в†’ **Import/Export** в†’ **Import Data** в†’ **From File**
3. Р’С‹Р±РµСЂРёС‚Рµ С„Р°Р№Р» `Insomnia_Collection_DEMO.json`
4. РџРѕРґС‚РІРµСЂРґРёС‚Рµ РёРјРїРѕСЂС‚

### РЁР°Рі 2: РќР°СЃС‚СЂРѕР№РєР° РїРµСЂРµРјРµРЅРЅС‹С… РѕРєСЂСѓР¶РµРЅРёСЏ
РџРѕСЃР»Рµ РёРјРїРѕСЂС‚Р° РѕС‚РєСЂРѕР№С‚Рµ **Environment** Рё Р·Р°РїРѕР»РЅРёС‚Рµ РїРµСЂРµРјРµРЅРЅС‹Рµ:

```json
{
  "base_url": "http://localhost:3000",
  "user_token": "",       // Р—Р°РїРѕР»РЅРёС‚СЃСЏ РїРѕСЃР»Рµ Р·Р°РїСЂРѕСЃР° #17
  "moderator_token": "",  // Р—Р°РїРѕР»РЅРёС‚СЃСЏ РїРѕСЃР»Рµ Р·Р°РїСЂРѕСЃР° #18
  "new_beam_id": "",      // Р—Р°РїРѕР»РЅРёС‚СЃСЏ РїРѕСЃР»Рµ Р·Р°РїСЂРѕСЃР° #5
  "draft_id": "",         // Р—Р°РїРѕР»РЅРёС‚СЃСЏ РїРѕСЃР»Рµ Р·Р°РїСЂРѕСЃР° #9
  "formed_id": "",        // РСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РІ РїСЂРёРјРµСЂР°С… (РѕРїС†РёРѕРЅР°Р»СЊРЅРѕ)
  "new_user_token": ""    // Р—Р°РїРѕР»РЅРёС‚СЃСЏ РїРѕСЃР»Рµ Р·Р°РїСЂРѕСЃР° #16
}
```

---

## рџЏ—пёЏ РњРѕРґРµР»Рё Рё СЃРµСЂРёР°Р»РёР·Р°С‚РѕСЂС‹

### РњРѕРґРµР»Рё

#### 1. User (`app/models/user.rb`)
**Р¤Р°Р№Р»:** `app/models/user.rb`

```ruby
class User < ApplicationRecord
  has_secure_password

  # РђСЃСЃРѕС†РёР°С†РёРё
  has_many :beam_deflections, foreign_key: :creator_id, dependent: :destroy
  has_many :moderated_beam_deflections, class_name: 'BeamDeflection', foreign_key: :moderator_id

  # Р’Р°Р»РёРґР°С†РёРё
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true

  # РњРµС‚РѕРґС‹
  def moderator?
    moderator
  end
end
```

**РџРѕР»СЏ:**
- `id` - PRIMARY KEY
- `email` - string, unique
- `password_digest` - string (bcrypt hash)
- `moderator` - boolean (default: false)

---

#### 2. Beam (`app/models/beam.rb`)
**Р¤Р°Р№Р»:** `app/models/beam.rb`

```ruby
class Beam < ApplicationRecord
  include BeamScopes

  # РђСЃСЃРѕС†РёР°С†РёРё
  has_many :beam_deflection_beams, dependent: :destroy
  has_many :beam_deflections, through: :beam_deflection_beams

  # Р’Р°Р»РёРґР°С†РёРё
  validates :name, presence: true
  validates :material, inclusion: { in: %w[wooden steel reinforced_concrete] }
  validates :elasticity_gpa, numericality: { greater_than: 0 }
  validates :inertia_cm4, numericality: { greater_than: 0 }
  validates :allowed_deflection_ratio, numericality: { greater_than: 0 }

  # РњРµС‚РѕРґС‹
  def image_url
    return MinioHelper.minio_image_url(image_key) if image_key.present?
    # Fallback SVG placeholder
  end
end
```

**РџРѕР»СЏ:**
- `id` - PRIMARY KEY
- `name` - string (РЅР°Р·РІР°РЅРёРµ Р±Р°Р»РєРё)
- `description` - text
- `material` - string (wooden/steel/reinforced_concrete)
- `elasticity_gpa` - decimal (РјРѕРґСѓР»СЊ СѓРїСЂСѓРіРѕСЃС‚Рё, Р“РџР°)
- `inertia_cm4` - decimal (РјРѕРјРµРЅС‚ РёРЅРµСЂС†РёРё, СЃРјвЃґ)
- `allowed_deflection_ratio` - decimal (РґРѕРїСѓСЃС‚РёРјРѕРµ СЃРѕРѕС‚РЅРѕС€РµРЅРёРµ РїСЂРѕРіРёР±Р°)
- `image_key` - string (РєР»СЋС‡ РёР·РѕР±СЂР°Р¶РµРЅРёСЏ РІ MinIO)
- `active` - boolean (soft delete)

---

#### 3. BeamDeflection (`app/models/beam_deflection.rb`)
**Р¤Р°Р№Р»:** `app/models/beam_deflection.rb`

```ruby
class BeamDeflection < ApplicationRecord
  include BeamDeflectionScopes

  # РђСЃСЃРѕС†РёР°С†РёРё
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  belongs_to :moderator, class_name: 'User', foreign_key: :moderator_id, optional: true
  has_many :beam_deflection_beams, dependent: :destroy
  has_many :beams, through: :beam_deflection_beams

  # Р’Р°Р»РёРґР°С†РёРё
  validates :status, presence: true
  validates :length_m, numericality: { greater_than: 0 }, allow_nil: true
  validates :udl_kn_m, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Singleton РґР»СЏ СЃРѕР·РґР°РЅРёСЏ draft Р·Р°СЏРІРєРё
  def self.ensure_draft_for(user)
    draft_for(user).first_or_create! do |request|
      request.creator = user
    end
  end

  # Р Р°СЃС‡РµС‚ РїСЂРѕРіРёР±Р°
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

**РџРѕР»СЏ:**
- `id` - PRIMARY KEY
- `creator_id` - foreign key в†’ users
- `moderator_id` - foreign key в†’ users (nullable)
- `status` - string (draft/formed/completed/rejected/deleted)
- `length_m` - decimal (РґР»РёРЅР° РїСЂРѕР»РµС‚Р°, РјРµС‚СЂС‹)
- `udl_kn_m` - decimal (СЂР°РІРЅРѕРјРµСЂРЅР°СЏ РЅР°РіСЂСѓР·РєР°, РєРќ/Рј)
- `note` - text
- `result_deflection_mm` - decimal (СЂРµР·СѓР»СЊС‚Р°С‚ СЂР°СЃС‡РµС‚Р°, РјРј)
- `within_norm` - boolean (РІ РїСЂРµРґРµР»Р°С… РЅРѕСЂРјС‹)
- `formed_at` - datetime (РґР°С‚Р° С„РѕСЂРјРёСЂРѕРІР°РЅРёСЏ)
- `completed_at` - datetime (РґР°С‚Р° Р·Р°РІРµСЂС€РµРЅРёСЏ)
- `calculated_at` - datetime (РґР°С‚Р° СЂР°СЃС‡РµС‚Р°)

---

#### 4. BeamDeflectionBeam (Рј-Рј)
**Р¤Р°Р№Р»:** `app/models/beam_deflection_beam.rb`

```ruby
class BeamDeflectionBeam < ApplicationRecord
  # РђСЃСЃРѕС†РёР°С†РёРё
  belongs_to :beam_deflection
  belongs_to :beam

  # Р’Р°Р»РёРґР°С†РёРё
  validates :quantity, numericality: { greater_than: 0 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :beam_id, uniqueness: { scope: :beam_deflection_id }
end
```

**РџРѕР»СЏ:**
- `id` - PRIMARY KEY
- `beam_deflection_id` - foreign key в†’ beam_deflections
- `beam_id` - foreign key в†’ beams
- `quantity` - integer (РєРѕР»РёС‡РµСЃС‚РІРѕ)
- `position` - integer (РїРѕСЂСЏРґРєРѕРІС‹Р№ РЅРѕРјРµСЂ)
- `is_primary` - boolean
- `deflection_mm` - decimal (СЂР°СЃС‡РµС‚РЅС‹Р№ РїСЂРѕРіРёР± РґР»СЏ СЌС‚РѕР№ Р±Р°Р»РєРё, РјРј)

---

### РЎРµСЂРёР°Р»РёР·Р°С‚РѕСЂС‹

Р’ Rails API РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ **СЂСѓС‡РЅР°СЏ СЃРµСЂРёР°Р»РёР·Р°С†РёСЏ** С‡РµСЂРµР· РјРµС‚РѕРґС‹ РєРѕРЅС‚СЂРѕР»Р»РµСЂР°, Р° РЅРµ Active Model Serializers.

#### РџСЂРёРјРµСЂ: BeamDeflection serializer
**Р¤Р°Р№Р»:** `app/controllers/api/beam_deflections_controller.rb:183-212`

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

**РћСЃРѕР±РµРЅРЅРѕСЃС‚Рё:**
- вњ… Р’РєР»СЋС‡Р°РµС‚ СЃРІСЏР·Р°РЅРЅС‹Рµ РґР°РЅРЅС‹Рµ (items СЃ beams)
- вњ… Р›РѕРіРёРЅС‹ С‡РµСЂРµР· email (creator_login, moderator_login)
- вњ… Image URL С‡РµСЂРµР· MinIO helper
- вњ… Р’С‹С‡РёСЃР»СЏРµРјС‹Рµ РїРѕР»СЏ (deflection_mm РґР»СЏ РєР°Р¶РґРѕР№ Р±Р°Р»РєРё)

#### РџСЂРёРјРµСЂ: Beam serializer
**Р¤Р°Р№Р»:** `app/controllers/api/beams_controller.rb:36`

```ruby
def show
  render json: @beam.as_json(methods: [:image_url])
end
```

РСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ СЃС‚Р°РЅРґР°СЂС‚РЅС‹Р№ `as_json` СЃ РґРѕР±Р°РІР»РµРЅРёРµРј РІС‹С‡РёСЃР»СЏРµРјРѕРіРѕ РјРµС‚РѕРґР° `image_url`.

---

## рџ”„ Р¤СѓРЅРєС†РёСЏ-singleton

### `ensure_draft_for(user)`

**Р¤Р°Р№Р»:** `app/models/beam_deflection.rb:35-39`

```ruby
def self.ensure_draft_for(user)
  draft_for(user).first_or_create! do |request|
    request.creator = user
  end
end
```

**РСЃРїРѕР»СЊР·РѕРІР°РЅРёРµ РІ РєРѕРЅС‚СЂРѕР»Р»РµСЂР°С…:**

#### 1. BeamsController#add_to_draft
**Р¤Р°Р№Р»:** `app/controllers/api/beams_controller.rb:66-80`

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
**Р¤Р°Р№Р»:** `app/controllers/api/beam_deflections/cart_badge_controller.rb:4-10`

```ruby
def cart_badge
  draft = BeamDeflection.ensure_draft_for(Current.user)
  render json: {
    beam_deflection_id: draft.id,
    items_count: draft.beam_deflection_beams.sum(:quantity)
  }
end
```

**РџСЂРёРЅС†РёРї СЂР°Р±РѕС‚С‹:**
1. вњ… **Singleton Pattern** - РґР»СЏ РєР°Р¶РґРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ СЃСѓС‰РµСЃС‚РІСѓРµС‚ С‚РѕР»СЊРєРѕ РћР”РќРђ draft Р·Р°СЏРІРєР°
2. вњ… **РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРµ СЃРѕР·РґР°РЅРёРµ** - РµСЃР»Рё draft РЅРµС‚, СЃРѕР·РґР°РµС‚СЃСЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРё
3. вњ… **РљРѕРЅСЃС‚Р°РЅС‚Р° СЃС‚Р°С‚СѓСЃР°** - РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ `STATUSES[:draft]` РёР· concern
4. вњ… **РСЃРїРѕР»СЊР·РѕРІР°РЅРёРµ РІ РјРµС‚РѕРґР°С…** - add_to_draft, cart_badge

**Scope `draft_for`:**
```ruby
scope :draft_for, ->(user) { where(creator: user, status: STATUSES[:draft]) }
```

---

## рџЋЇ РџРѕСЂСЏРґРѕРє РІС‹РїРѕР»РЅРµРЅРёСЏ С‚РµСЃС‚РѕРІ

### РџРѕРґРіРѕС‚РѕРІРєР° (РІС‹РїРѕР»РЅРёС‚СЊ РѕРґРёРЅ СЂР°Р·)

#### 1. Р—Р°РїСѓСЃС‚РёС‚СЊ СЃРµСЂРІРёСЃС‹
```bash
docker-compose up
```

#### 2. РЎРѕР·РґР°С‚СЊ РґРµРјРѕ-РїРѕР»СЊР·РѕРІР°С‚РµР»РµР№ (РµСЃР»Рё РµС‰Рµ РЅРµ СЃРѕР·РґР°РЅС‹)
```bash
docker-compose exec web bin/rails runner utilities/scripts/prepare_demo.rb
```

---

### РўРµСЃС‚РёСЂРѕРІР°РЅРёРµ (РїРѕ РїРѕСЂСЏРґРєСѓ РїРѕРєР°Р·Р°)

| в„– | Р—Р°РїСЂРѕСЃ | Р§С‚Рѕ РїСЂРѕРІРµСЂСЏРµС‚СЃСЏ | Р”РµР№СЃС‚РІРёРµ РїРѕСЃР»Рµ |
|---|--------|-----------------|----------------|
| **17** | POST Sign In (User) | РђСѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ | вњЏпёЏ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ `token` в†’ `user_token` |
| **18** | POST Sign In (Moderator) | РђСѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ РјРѕРґРµСЂР°С‚РѕСЂР° | вњЏпёЏ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ `token` в†’ `moderator_token` |
| **01** | GET РЎРїРёСЃРѕРє Р·Р°СЏРІРѕРє (С„РёР»СЊС‚СЂ) | Р¤РёР»СЊС‚СЂР°С†РёСЏ РїРѕ РґР°С‚Рµ Рё СЃС‚Р°С‚СѓСЃСѓ | РЈРІРёРґРµС‚СЊ completed Р·Р°СЏРІРєРё |
| **02** | GET РРєРѕРЅРєРё РєРѕСЂР·РёРЅС‹ | Singleton draft Р·Р°СЏРІРєРё | Р—Р°РїРѕРјРЅРёС‚СЊ `beam_deflection_id` |
| **03** | DELETE Р—Р°СЏРІРєСѓ | РЈРґР°Р»РµРЅРёРµ draft (РµСЃР»Рё РµСЃС‚СЊ) | вњЏпёЏ РћР±РЅРѕРІРёС‚СЊ `draft_id` РµСЃР»Рё РЅСѓР¶РЅРѕ |
| **04** | GET РЎРїРёСЃРѕРє СѓСЃР»СѓРі (С„РёР»СЊС‚СЂ) | Р¤РёР»СЊС‚СЂР°С†РёСЏ РїРѕ active, search | Р’С‹Р±СЂР°С‚СЊ ID Р±Р°Р»РѕРє |
| **05** | POST РќРѕРІР°СЏ СѓСЃР»СѓРіР° | РЎРѕР·РґР°РЅРёРµ Р±РµР· РёР·РѕР±СЂР°Р¶РµРЅРёСЏ | вњЏпёЏ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ `id` в†’ `new_beam_id` |
| **06** | POST Р”РѕР±Р°РІРёС‚СЊ РёР·РѕР±СЂР°Р¶РµРЅРёРµ | MinIO, Р»Р°С‚РёРЅРёС†Р° РІ РЅР°Р·РІР°РЅРёРё | РџСЂРѕРІРµСЂРёС‚СЊ `image_url` |
| **07** | POST Р”РѕР±Р°РІРёС‚СЊ СѓСЃР»СѓРіСѓ #1 | Р”РѕР±Р°РІР»РµРЅРёРµ РІ draft (ID=39) | Р—Р°РїРѕРјРЅРёС‚СЊ `items_count` |
| **08** | POST Р”РѕР±Р°РІРёС‚СЊ СѓСЃР»СѓРіСѓ #2 | Р”РѕР±Р°РІР»РµРЅРёРµ РІ draft (ID=40) | Р—Р°РїРѕРјРЅРёС‚СЊ РЅРѕРІС‹Р№ `items_count` |
| **09** | GET РРєРѕРЅРєРё РєРѕСЂР·РёРЅС‹ | РџСЂРѕРІРµСЂРєР° РєРѕР»РёС‡РµСЃС‚РІР° (5 СѓСЃР»СѓРі) | вњЏпёЏ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ `beam_deflection_id` в†’ `draft_id` |
| **10** | GET Р—Р°СЏРІРєСѓ | РџСЂРѕСЃРјРѕС‚СЂ Р·Р°СЏРІРєРё СЃ 2 СѓСЃР»СѓРіР°РјРё | РЈРІРёРґРµС‚СЊ items СЃ РёР·РѕР±СЂР°Р¶РµРЅРёСЏРјРё |
| **11** | PUT РР·РјРµРЅРёС‚СЊ Рј-Рј | РР·РјРµРЅРµРЅРёРµ quantity/position Р±РµР· PK | РџСЂРѕРІРµСЂРёС‚СЊ РёР·РјРµРЅРµРЅРёСЏ |
| **12** | PUT РР·РјРµРЅРёС‚СЊ Р·Р°СЏРІРєСѓ | РР·РјРµРЅРµРЅРёРµ length_m, udl_kn_m | РџСЂРѕРІРµСЂРёС‚СЊ РѕР±РЅРѕРІР»РµРЅРёРµ |
| **13** | PUT Р—Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ | вќЊ РћРЁРР‘РљРђ (draft status) | РЈРІРёРґРµС‚СЊ 422 РѕС€РёР±РєСѓ |
| **14** | PUT РЎС„РѕСЂРјРёСЂРѕРІР°С‚СЊ Р·Р°СЏРІРєСѓ | РџСЂРѕРІРµСЂРєР° РѕР±СЏР·Р°С‚РµР»СЊРЅС‹С… РїРѕР»РµР№ | РЈРІРёРґРµС‚СЊ `formed_at` |
| **15** | PUT Р—Р°РІРµСЂС€РёС‚СЊ Р·Р°СЏРІРєСѓ | вњ… Р Р°СЃС‡РµС‚ РїСЂРѕРіРёР±Р° РїРѕ С„РѕСЂРјСѓР»Рµ | РЈРІРёРґРµС‚СЊ `result_deflection_mm` |
| **16** | POST Р РµРіРёСЃС‚СЂР°С†РёСЏ | РЎРѕР·РґР°РЅРёРµ РЅРѕРІРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ | вњЏпёЏ РЎРєРѕРїРёСЂРѕРІР°С‚СЊ `token` |
| **19** | GET РўРµРєСѓС‰РёР№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ | Р”Р°РЅРЅС‹Рµ Р»РёС‡РЅРѕРіРѕ РєР°Р±РёРЅРµС‚Р° | РЈРІРёРґРµС‚СЊ email, moderator |
| **20** | PUT РћР±РЅРѕРІРёС‚СЊ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ | РР·РјРµРЅРµРЅРёРµ email/password | РџСЂРѕРІРµСЂРёС‚СЊ РѕР±РЅРѕРІР»РµРЅРёРµ |
| **21** | POST Р”РµР°РІС‚РѕСЂРёР·Р°С†РёСЏ | JWT blacklist РІ Redis | Token СЃС‚Р°РЅРµС‚ РЅРµРІР°Р»РёРґРЅС‹Рј |

---

## рџ”Ќ SQL Р·Р°РїСЂРѕСЃС‹ РґР»СЏ РїСЂРѕРІРµСЂРєРё

РџРѕСЃР»Рµ РІС‹РїРѕР»РЅРµРЅРёСЏ С‚РµСЃС‚РѕРІ РјРѕР¶РЅРѕ РїСЂРѕРІРµСЂРёС‚СЊ РґР°РЅРЅС‹Рµ С‡РµСЂРµР· Rails console:

```bash
docker-compose exec web bin/rails console
```

### 1. РџСЂРѕРІРµСЂРёС‚СЊ СЃРѕР·РґР°РЅРЅСѓСЋ СѓСЃР»СѓРіСѓ
```ruby
# РќР°Р№С‚Рё РїРѕСЃР»РµРґРЅСЋСЋ СЃРѕР·РґР°РЅРЅСѓСЋ Р±Р°Р»РєСѓ
beam = Beam.last
puts "Name: #{beam.name}"
puts "Image Key: #{beam.image_key}"
puts "Image URL: #{beam.image_url}"
```

### 2. РџСЂРѕРІРµСЂРёС‚СЊ Р·Р°СЏРІРєСѓ СЃ СЂР°СЃС‡РµС‚РѕРј
```ruby
# РќР°Р№С‚Рё РїРѕСЃР»РµРґРЅСЋСЋ completed Р·Р°СЏРІРєСѓ
bd = BeamDeflection.completed.last

puts "Status: #{bd.status}"
puts "Creator: #{bd.creator.email}"
puts "Moderator: #{bd.moderator.email}"
puts "Length: #{bd.length_m} m"
puts "UDL: #{bd.udl_kn_m} kN/m"
puts "Result Deflection: #{bd.result_deflection_mm} mm"
puts "Within Norm: #{bd.within_norm}"

# РџСЂРѕСЃРјРѕС‚СЂ items
bd.beam_deflection_beams.each do |item|
  puts "  - #{item.beam.name} x#{item.quantity}: #{item.deflection_mm} mm"
end
```

### 3. РџСЂРѕРІРµСЂРёС‚СЊ singleton draft
```ruby
user = User.find_by(email: 'user@demo.com')

# РќР°Р№С‚Рё draft
draft = BeamDeflection.draft_for(user).first
puts "Draft ID: #{draft.id}"
puts "Items count: #{draft.beam_deflection_beams.count}"

# РџСЂРѕРІРµСЂРёС‚СЊ singleton (РґРѕР»Р¶РµРЅ РІРµСЂРЅСѓС‚СЊ С‚РѕС‚ Р¶Рµ РѕР±СЉРµРєС‚)
draft2 = BeamDeflection.ensure_draft_for(user)
puts "Same object? #{draft.id == draft2.id}" # => true
```

### 4. РџСЂРѕРІРµСЂРёС‚СЊ С„РѕСЂРјСѓР»Сѓ СЂР°СЃС‡РµС‚Р°
```ruby
# Р’СЂСѓС‡РЅСѓСЋ СЂР°СЃСЃС‡РёС‚Р°С‚СЊ РїСЂРѕРіРёР± РґР»СЏ РѕРґРЅРѕР№ Р±Р°Р»РєРё
bd = BeamDeflection.last
beam = Beam.find(39)

q = bd.udl_kn_m * 1000  # РєРќ/Рј -> Рќ/Рј
l = bd.length_m
e = beam.elasticity_gpa * 1e9  # Р“РџР° -> РџР°
j = beam.inertia_cm4 * 1e-8  # СЃРјвЃґ -> РјвЃґ

deflection = (5 * q * (l ** 4)) / (384 * e * j) * 1000  # РІ РјРј

puts "Calculated: #{deflection} mm"
puts "Stored: #{bd.beam_deflection_beams.find_by(beam_id: 39).deflection_mm} mm"
```

### 5. РџСЂРѕРІРµСЂРёС‚СЊ Redis blacklist
```bash
docker-compose exec redis redis-cli
```

```redis
# РџРѕСЃРјРѕС‚СЂРµС‚СЊ РІСЃРµ blacklist РєР»СЋС‡Рё
KEYS "jwt:blacklist:*"

# РџСЂРѕРІРµСЂРёС‚СЊ TTL РєР»СЋС‡Р°
TTL "jwt:blacklist:<hash>"

# РџРѕСЃРјРѕС‚СЂРµС‚СЊ Р·РЅР°С‡РµРЅРёРµ
GET "jwt:blacklist:<hash>"
```

### 6. РџСЂРѕРІРµСЂРёС‚СЊ MinIO
```bash
# Web UI: http://localhost:9001
# Login: minioadmin / minioadmin

# РР»Рё С‡РµСЂРµР· CLI
docker-compose exec minio mc ls minio/beam-deflection
```

---

## рџ“Љ РћР¶РёРґР°РµРјС‹Рµ СЂРµР·СѓР»СЊС‚Р°С‚С‹

### РџРѕСЃР»Рµ РІС‹РїРѕР»РЅРµРЅРёСЏ РІСЃРµС… С‚РµСЃС‚РѕРІ:

**Users:**
- вњ… user@demo.com (ID: 39)
- вњ… moderator@demo.com (ID: 40)
- вњ… newuser@test.com (РЅРѕРІС‹Р№)

**Beams:**
- вњ… 9 СЃСѓС‰РµСЃС‚РІСѓСЋС‰РёС… Р±Р°Р»РѕРє
- вњ… 1 РЅРѕРІР°СЏ "Test Beam Demo" СЃ РёР·РѕР±СЂР°Р¶РµРЅРёРµРј

**BeamDeflections:**
- вњ… 1 completed Р·Р°СЏРІРєР° СЃ СЂР°СЃС‡РµС‚РѕРј РїСЂРѕРіРёР±Р°
- вњ… 1 draft Р·Р°СЏРІРєР° (РµСЃР»Рё РЅРµ СѓРґР°Р»РёР»Рё)

**Redis:**
- вњ… 1+ blacklist РєР»СЋС‡РµР№

**MinIO:**
- вњ… РР·РѕР±СЂР°Р¶РµРЅРёРµ РЅРѕРІРѕР№ Р±Р°Р»РєРё РІ bucket

---

## рџЋ“ РћР±СЉСЏСЃРЅРµРЅРёРµ РґР»СЏ РґРµРјРѕРЅСЃС‚СЂР°С†РёРё

### РњРѕРґРµР»Рё
1. **User** - Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёСЏ С‡РµСЂРµР· bcrypt, СЂРѕР»Рё (moderator)
2. **Beam** - СѓСЃР»СѓРіРё СЃ РјР°С‚РµСЂРёР°Р»Р°РјРё Рё С„РёР·РёС‡РµСЃРєРёРјРё СЃРІРѕР№СЃС‚РІР°РјРё
3. **BeamDeflection** - Р·Р°СЏРІРєРё СЃ state machine
4. **BeamDeflectionBeam** - Рј-Рј СЃ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹РјРё РїРѕР»СЏРјРё (quantity, position, deflection_mm)

### РЎРµСЂРёР°Р»РёР·Р°С‚РѕСЂС‹
- Р СѓС‡РЅР°СЏ СЃРµСЂРёР°Р»РёР·Р°С†РёСЏ С‡РµСЂРµР· РјРµС‚РѕРґС‹ РєРѕРЅС‚СЂРѕР»Р»РµСЂР°
- Р’РєР»СЋС‡РµРЅРёРµ СЃРІСЏР·Р°РЅРЅС‹С… РґР°РЅРЅС‹С… (eager loading)
- Р›РѕРіРёРЅС‹ С‡РµСЂРµР· email РІРјРµСЃС‚Рѕ ID
- Р’С‹С‡РёСЃР»СЏРµРјС‹Рµ РїРѕР»СЏ (image_url, items_with_result_count)

### Р¤СѓРЅРєС†РёСЏ-singleton
- **`ensure_draft_for(user)`** - РіР°СЂР°РЅС‚РёСЂСѓРµС‚ РµРґРёРЅСЃС‚РІРµРЅРЅСѓСЋ draft Р·Р°СЏРІРєСѓ РґР»СЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ
- РСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РІ `add_to_draft` Рё `cart_badge`
- РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРµ СЃРѕР·РґР°РЅРёРµ РїСЂРё РѕС‚СЃСѓС‚СЃС‚РІРёРё

### Р¤РѕСЂРјСѓР»Р° СЂР°СЃС‡РµС‚Р°
```
w = 5 * q * LвЃґ / (384 * E * J)

РіРґРµ:
  q - РЅР°РіСЂСѓР·РєР° (Рќ/Рј)
  L - РґР»РёРЅР° РїСЂРѕР»РµС‚Р° (Рј)
  E - РјРѕРґСѓР»СЊ СѓРїСЂСѓРіРѕСЃС‚Рё (РџР°)
  J - РјРѕРјРµРЅС‚ РёРЅРµСЂС†РёРё (РјвЃґ)
  w - РїСЂРѕРіРёР± (Рј) в†’ * 1000 = РјРј
```

---

**Р“РѕС‚РѕРІРѕ Рє РґРµРјРѕРЅСЃС‚СЂР°С†РёРё!** рџљЂ

