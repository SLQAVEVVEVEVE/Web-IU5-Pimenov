class FixRequestsServicesSchema < ActiveRecord::Migration[8.0]
  def change
    # quantity
    unless column_exists?(:requests_services, :quantity)
      add_column :requests_services, :quantity, :integer, null: false, default: 1
    end

    # position/order inside the request (optional field)
    unless column_exists?(:requests_services, :position)
      add_column :requests_services, :position, :integer
    end

    # main/primary flag
    unless column_exists?(:requests_services, :is_primary)
      add_column :requests_services, :is_primary, :boolean, null: false, default: false
    end

    # composite unique key: one service per request
    unless index_exists?(:requests_services, [:request_id, :service_id], unique: true)
      add_index :requests_services, [:request_id, :service_id], unique: true, name: "idx_requests_services_unique"
    end
  end
end
