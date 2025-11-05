class AddDeflectionMmToRequestsServices < ActiveRecord::Migration[7.1]
  def change
    add_column :requests_services, :deflection_mm, :decimal, precision: 18, scale: 6, null: true
  end
end
