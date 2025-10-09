class FixDeflectionRequestStatusDefault < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE deflection_requests SET status = 0 WHERE status IS NULL"
    change_column :deflection_requests, :status, :integer, null: false, default: 0
  end

  def down
    change_column :deflection_requests, :status, :integer, null: true, default: nil
  end
end
