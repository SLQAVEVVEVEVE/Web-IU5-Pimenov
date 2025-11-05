class AddResultDeflectionToRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :requests, :result_deflection_mm, :decimal, precision: 18, scale: 6, null: true
    add_column :requests, :calculated_at, :datetime, null: true
  end
end
