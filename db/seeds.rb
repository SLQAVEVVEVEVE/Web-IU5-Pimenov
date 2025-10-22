# frozen_string_literal: true

demo = User.find_or_create_by!(email: "demo@local") do |u|
  u.password     = "demo12345"
  u.is_moderator = false
end

# === 2) Нормализация материалов и норм (без валидаций) ===
MATERIALS_MAP = {
  "Дерево"       => BeamType::MATERIALS[:wood],
  "Сталь"        => BeamType::MATERIALS[:steel],
  "Железобетон"  => BeamType::MATERIALS[:reinforced_concrete],
  "Композит"     => BeamType::MATERIALS[:composite],
  # на всякий случай — возможные варианты из старых сидов/ручных правок:
  "дерево"       => BeamType::MATERIALS[:wood],
  "сталь"        => BeamType::MATERIALS[:steel],
  "железобетон"  => BeamType::MATERIALS[:reinforced_concrete],
  "композит"     => BeamType::MATERIALS[:composite]
}.freeze

BeamType.find_each do |bt|
  # 1) material → нормализуем, обходя валидации
  if !BeamType::MATERIALS.values.include?(bt.material)
    new_mat = MATERIALS_MAP[bt.material]
    # если совсем неизвестное значение — по умолчанию "steel"
    new_mat ||= BeamType::MATERIALS[:steel]
    bt.update_columns(material: new_mat)
  end

  # 2) norm: если строка (например, "L/250"), приводим к демо-значению в мм
  if bt.norm.is_a?(String)
    demo_mm =
      case bt.material
      when BeamType::MATERIALS[:steel]               then 3.0
      when BeamType::MATERIALS[:wood]                then 8.0
      when BeamType::MATERIALS[:reinforced_concrete] then 6.0
      else 7.0
      end
    bt.update_columns(norm: demo_mm)
  end
end

# === 3) Базовые типы балок (upsert) ===
seed_beam_types = [
  {
    name: "Деревянная балка",
    material: BeamType::MATERIALS[:wood],
    elasticity_gpa: 10.0,
    norm: 8.0,
    image_key: "wood.jpg",
    archived: false
  },
  {
    name: "Стальная балка",
    material: BeamType::MATERIALS[:steel],
    elasticity_gpa: 200.0,
    norm: 3.0,
    image_key: "steel.jpg",
    archived: false
  },
  {
    name: "Железобетонная балка",
    material: BeamType::MATERIALS[:reinforced_concrete],
    elasticity_gpa: 30.0,
    norm: 6.0,
    image_key: "rc.jpg",
    archived: false
  },
  {
    name: "Клеёный брус (GL24h)",
    material: BeamType::MATERIALS[:composite],
    elasticity_gpa: 11.5,
    norm: 7.0,
    image_key: "glulam.jpg",
    archived: false
  }
]

seed_beam_types.each do |attrs|
  bt = BeamType.find_or_initialize_by(name: attrs[:name])
  bt.assign_attributes(attrs)
  bt.save!
end

bt_wood  = BeamType.find_by!(name: "Деревянная балка")
bt_steel = BeamType.find_by!(name: "Стальная балка")

lf = LoadForecast.find_or_create_by!(requester_id: demo.id, status: LoadForecast::STATUS[:pending]) do |rec|
  rec.formed_at    = nil
  rec.completed_at = nil
  rec.moderator_id = nil
end

lfbt_pairs = [
  { beam_type: bt_wood,  length_m: 3.0, load_kn_m: 5.0, quantity: 1 },
  { beam_type: bt_steel, length_m: 3.0, load_kn_m: 5.0, quantity: 2 }
]

lfbt_pairs.each do |h|
  rec = LoadForecastBeamType.find_or_initialize_by(
  load_forecast_id: lf.id,
  beam_type_id:     h[:beam_type].id,
  length_m:         h[:length_m],
  load_kn_m:        h[:load_kn_m]
  )
  rec.quantity = h[:quantity]
  rec.save!
end

puts "Seeded: users=#{User.count}, beam_types=#{BeamType.count}, load_forecasts=#{LoadForecast.count}, lfbt=#{LoadForecastBeamType.count}"
