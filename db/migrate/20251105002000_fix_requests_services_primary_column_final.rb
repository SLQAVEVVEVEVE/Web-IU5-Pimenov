# db/migrate/20251105002000_fix_requests_services_primary_column_final.rb
class FixRequestsServicesPrimaryColumnFinal < ActiveRecord::Migration[8.0]
  def up
    # Rename column if it's still named "primary"
    if column_exists?(:requests_services, :primary) && !column_exists?(:requests_services, :is_primary)
      execute "UPDATE requests_services SET primary = false WHERE primary IS NULL;"
      rename_column :requests_services, :primary, :is_primary
    end

    # Enforce default/NOT NULL for is_primary
    if column_exists?(:requests_services, :is_primary)
      change_column_default :requests_services, :is_primary, from: nil, to: false
      execute "UPDATE requests_services SET is_primary = false WHERE is_primary IS NULL;"
      change_column_null :requests_services, :is_primary, false
    end

    # Make sure quantity is sane
    if column_exists?(:requests_services, :quantity)
      change_column_default :requests_services, :quantity, from: nil, to: 1
      execute "UPDATE requests_services SET quantity = 1 WHERE quantity IS NULL;"
      change_column_null :requests_services, :quantity, false
    end

    # Unique pair (request_id, service_id)
    unless index_exists?(:requests_services, [:request_id, :service_id], unique: true, name: "idx_requests_services_unique")
      add_index :requests_services, [:request_id, :service_id], unique: true, name: "idx_requests_services_unique"
    end
  end

  def down
    # Soft rollback (keep safe)
    if column_exists?(:requests_services, :is_primary) && !column_exists?(:requests_services, :primary)
      rename_column :requests_services, :is_primary, :primary
    end
    # We won't drop constraints/indexes on down.
  end
end
