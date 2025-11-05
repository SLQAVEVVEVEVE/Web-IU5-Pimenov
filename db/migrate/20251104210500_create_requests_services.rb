class CreateRequestsServices < ActiveRecord::Migration[8.0]
  def change
    create_table :requests_services do |t|
      t.references :request, null: false, foreign_key: { on_delete: :restrict }, index: false
      t.references :service, null: false, foreign_key: { on_delete: :restrict }, index: false
      t.integer :quantity, null: false, default: 1
      t.integer :position, null: false, default: 1
      t.boolean :primary, null: false, default: false
      
      t.timestamps
      
      t.index [:request_id, :service_id], unique: true, name: 'index_requests_services_on_request_and_service'
    end
    
    execute <<-SQL
      ALTER TABLE requests_services 
      ADD CONSTRAINT check_quantity_positive 
      CHECK (quantity > 0);
      
      ALTER TABLE requests_services 
      ADD CONSTRAINT check_position_positive 
      CHECK (position > 0);
    SQL
  end
end
