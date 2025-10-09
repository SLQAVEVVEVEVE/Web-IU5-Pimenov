class CreateBeamTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :beam_types do |t|
      t.string  :name,           null: false
      t.string  :material
      t.integer :elasticity_gpa          # ГПа
      t.string  :norm
      t.string  :image_key
      t.boolean :archived,       null: false, default: false
      t.timestamps
    end
    add_index :beam_types, :name
    add_index :beam_types, :archived
  end
end
