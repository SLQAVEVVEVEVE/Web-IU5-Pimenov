class AddDeletedAtToBeamTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :beam_types, :deleted_at, :datetime
    add_index :beam_types, :deleted_at
  end
end
