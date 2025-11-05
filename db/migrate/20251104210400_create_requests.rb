class CreateRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :requests do |t|
      t.string :status, null: false, default: 'draft'
      t.references :creator, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.references :moderator, foreign_key: { to_table: :users, on_delete: :nullify }
      t.datetime :formed_at
      t.datetime :completed_at
      t.decimal :length_m, precision: 8, scale: 3, null: false
      t.decimal :udl_kn_m, precision: 8, scale: 3, null: false
      t.decimal :deflection_mm, precision: 10, scale: 3
      t.boolean :within_norm
      t.text :note
      
      t.timestamps
      
      t.index [:status, :creator_id]
    end
    
    execute <<-SQL
      ALTER TABLE requests 
      ADD CONSTRAINT check_status 
      CHECK (status IN ('draft', 'deleted', 'formed', 'completed', 'rejected'));
      
      ALTER TABLE requests 
      ADD CONSTRAINT check_length_positive 
      CHECK (length_m > 0);
      
      ALTER TABLE requests 
      ADD CONSTRAINT check_udl_non_negative 
      CHECK (udl_kn_m >= 0);
      
      CREATE UNIQUE INDEX idx_requests_single_draft_per_user
      ON requests (creator_id)
      WHERE status = 'draft';
    SQL
  end
end
