# Пользователь (демо)
demo = User.find_or_create_by!(email: "demo@local") do |u|
  u.password = "demo12345"
  u.is_moderator = false
end

# Типы балок
BeamType.find_or_create_by!(name: "Деревянная балка") do |b|
  b.material = "Дерево"
  b.elasticity_gpa = 10
  b.norm = "L/250"
  b.image_key = "wood.jpg"
  b.archived = false
end

BeamType.find_or_create_by!(name: "Стальная балка") do |b|
  b.material = "Сталь"
  b.elasticity_gpa = 200
  b.norm = "L/250"
  b.image_key = "steel.jpg"
  b.archived = false
end

BeamType.find_or_create_by!(name: "Железобетонная балка") do |b|
  b.material = "Железобетон"
  b.elasticity_gpa = 30
  b.norm = "L/250"
  b.image_key = "rc.jpg"
  b.archived = false
end

# Заявка-черновик
dr = DeflectionRequest.find_by(requester_id: demo.id, status: DeflectionRequest::STATUS[:draft]) ||
     DeflectionRequest.create!(
       requester_id: demo.id,
       status: DeflectionRequest::STATUS[:draft],
       length_m: 3.0,
       load_kN_m: 5.0
     )

# Привязки м-м
bt_wood  = BeamType.find_by!(name: "Деревянная балка")
bt_steel = BeamType.find_by!(name: "Стальная балка")

DeflectionRequestBeamType.find_or_create_by!(deflection_request: dr, beam_type: bt_wood) do |ri|
  ri.quantity = 1
  ri.primary  = true
end

DeflectionRequestBeamType.find_or_create_by!(deflection_request: dr, beam_type: bt_steel) do |ri|
  ri.quantity = 2
end
