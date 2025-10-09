class CreateDeflectionRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :deflection_requests do |t|
      t.integer  :status,       null: false, default: 0   # draft=0, deleted=1, formed=2, completed=3, rejected=4
      t.integer  :requester_id, null: false
      t.integer  :engineer_id
      t.datetime :formed_at
      t.datetime :completed_at

      t.decimal  :length_m,   precision: 10, scale: 3
      t.decimal  :load_kN_m,  precision: 10, scale: 3
      t.decimal  :result_mm,  precision: 10, scale: 3

      t.timestamps
    end
    add_index :deflection_requests, :requester_id

    # один черновик на пользователя
    execute <<~SQL
      CREATE UNIQUE INDEX idx_deflection_requests_one_draft_per_user
      ON deflection_requests(requester_id) WHERE status = 0;
    SQL
  end
end
