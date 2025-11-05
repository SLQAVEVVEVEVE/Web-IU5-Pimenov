class AddImageKeyToServicesAndIndexes < ActiveRecord::Migration[7.0]
  def change
    # Add image_key to services
    add_column :services, :image_key, :string

    # Add unique index on requests_services
    add_index :requests_services, [:request_id, :service_id], unique: true

    # Add indexes for performance
    add_index :requests, :status
    add_index :requests, :formed_at
  end
end
