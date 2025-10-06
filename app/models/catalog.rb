# frozen_string_literal: true
module Catalog
  Service = Struct.new(:id, :name, :material, :e_gpa, :norm, :image_key, :price, :description, keyword_init: true)

  def self.services
    @services ||= [
      Service.new(id: 1, name: "Деревянная балка", material: "Дерево", e_gpa: 10, norm: "L/250",
                  image_key: "wood.jpg", price: 1200, description: "E≈10 ГПа. Применение в малоэтажном строительстве."),
      Service.new(id: 2, name: "Стальная балка", material: "Сталь", e_gpa: 200, norm: "L/250",
                  image_key: "steel.jpg", price: 5200, description: "E≈200 ГПа, высокая несущая способность."),
      Service.new(id: 3, name: "Железобетонная балка", material: "Ж/б", e_gpa: 30, norm: "L/250",
                  image_key: "rc.jpg", price: 3400, description: "E≈30 ГПа, массовое применение."),
      Service.new(id: 4, name: "Алюминиевая балка", material: "Al", e_gpa: 69, norm: "L/200",
                  image_key: "aluminum.jpg", price: 4100, description: "E≈69 ГПа, малая масса.")
    ]
  end

  def self.order(order_id = 101)
    { id: order_id, items: [{ service_id: 1, qty: 1 }, { service_id: 2, qty: 2 }], result_mm: 12.4 }
  end
end
