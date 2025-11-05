services = [
  { 
    name: "Деревянная балка",  
    material: "wooden",              
    elasticity_gpa: 10,  
    inertia_cm4: 80000,  
    allowed_deflection_ratio: 250, 
    description: "Деревянные балки изготавливаются из цельного бруса или клееного бруса. Обладают хорошими теплоизоляционными свойствами и экологичностью. Требуют защиты от влаги и вредителей.",
    image_url: "beams/wood.jpg"
  },
  { 
    name: "Стальная балка",    
    material: "steel",               
    elasticity_gpa: 200, 
    inertia_cm4: 120000, 
    allowed_deflection_ratio: 250, 
    description: "Стальные балки обладают высокой прочностью и долговечностью. Используются в ответственных конструкциях, где важна несущая способность. Требуют антикоррозионной защиты.",
    image_url: "beams/steel.jpg"
  },
  { 
    name: "Железобетонная балка", 
    material: "reinforced_concrete", 
    elasticity_gpa: 30,  
    inertia_cm4: 100000, 
    allowed_deflection_ratio: 250, 
    description: "Железобетонные балки сочетают прочность металла и бетона. Отличаются высокой огнестойкостью и долговечностью. Применяются в капитальном строительстве.",
    image_url: "beams/rc.jpg"
  }
]

services.each do |attrs|
  s = Service.find_or_initialize_by(name: attrs[:name])
  s.assign_attributes(attrs.except(:image_url))
  s.image_url ||= attrs[:image_url] # Only set if not already present
  s.active = true if s.respond_to?(:active=)
  s.save!
end

puts "Seeded services: #{Service.count}"
