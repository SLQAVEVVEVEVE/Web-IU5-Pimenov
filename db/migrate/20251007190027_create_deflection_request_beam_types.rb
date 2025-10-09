class CreateDeflectionRequestBeamTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :deflection_request_beam_types do |t|
      t.references :deflection_request, null: false, foreign_key: { on_delete: :restrict }
      t.references :beam_type,          null: false, foreign_key: { on_delete: :restrict }
      t.integer    :quantity,           null: false, default: 1
      t.integer    :position
      t.boolean    :primary,            null: false, default: false
      t.string     :note
      t.timestamps
    end

    add_index :deflection_request_beam_types,
              [:deflection_request_id, :beam_type_id],
              unique: true, name: "ux_deflection_request_beam_type"
  end
end
