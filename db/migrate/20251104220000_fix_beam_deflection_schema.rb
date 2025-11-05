class FixBeamDeflectionSchema < ActiveRecord::Migration[8.0]
  # Helper methods for idempotent migrations
  def column_exists?(table, column)
    connection.column_exists?(table, column)
  end

  def index_exists?(table, columns, **options)
    return false unless table_exists?(table)
    connection.index_exists?(table, columns, **options)
  end

  def add_column_if_missing(table, column, type, **options)
    return if column_exists?(table, column)
    add_column(table, column, type, **options)
  end

  def remove_column_if_exists(table, column)
    remove_column(table, column) if column_exists?(table, column)
  end

  def add_reference_if_missing(table, ref, **options)
    return if column_exists?(table, "#{ref}_id")
    add_reference(table, ref, **options)
  end

  def add_index_if_missing(table, columns, **options)
    name = options[:name] || "idx_#{table}_on_#{Array(columns).join('_and_')}"
    return if index_exists?(table, columns, name: name)
    add_index(table, columns, **options)
  end

  def change
    # Services table
    add_column_if_missing :services, :description, :text
    add_column_if_missing :services, :material, :string, null: false
    add_column_if_missing :services, :elasticity_gpa, :decimal, precision: 6, scale: 2, null: false
    add_column_if_missing :services, :inertia_cm4, :decimal, precision: 12, scale: 2, null: false
    add_column_if_missing :services, :allowed_deflection_ratio, :integer, null: false, default: 250
    add_column_if_missing :services, :image_url, :string
    add_column_if_missing :services, :active, :boolean, null: false, default: true

    # Requests table
    add_column_if_missing :requests, :status, :string, null: false, default: "draft"
    add_reference_if_missing :requests, :creator, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
    add_column_if_missing :requests, :formed_at, :datetime
    add_column_if_missing :requests, :completed_at, :datetime
    add_reference_if_missing :requests, :moderator, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
    add_column_if_missing :requests, :length_m, :decimal, precision: 8, scale: 3
    add_column_if_missing :requests, :udl_kn_m, :decimal, precision: 8, scale: 3
    add_column_if_missing :requests, :deflection_mm, :decimal, precision: 10, scale: 3
    add_column_if_missing :requests, :within_norm, :boolean

    # Add partial unique index for one draft per user
    unless index_exists?(:requests, :creator_id, name: "idx_requests_single_draft_per_user")
      add_index :requests, :creator_id, 
                name: "idx_requests_single_draft_per_user", 
                unique: true, 
                where: "status = 'draft'"
    end

    # RequestsServices join table
    unless table_exists?(:requests_services)
      create_table :requests_services do |t|
        t.references :request, null: false, foreign_key: { on_delete: :restrict }
        t.references :service, null: false, foreign_key: { on_delete: :restrict }
        t.integer :quantity, null: false, default: 1
        t.boolean :is_primary, null: false, default: false
        t.timestamps
      end

      add_index :requests_services, [:request_id, :service_id], 
                unique: true, 
                name: "idx_req_srv_unique"
    end
  end
end
