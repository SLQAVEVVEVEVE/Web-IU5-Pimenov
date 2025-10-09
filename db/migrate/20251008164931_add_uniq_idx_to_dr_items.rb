class AddUniqIdxToDrItems < ActiveRecord::Migration[7.2]
  def change
    add_index :deflection_request_beam_types,
              [:deflection_request_id, :beam_type_id],
              unique: true,
              name: "idx_dr_items_uniq",
              if_not_exists: true
  end
end

