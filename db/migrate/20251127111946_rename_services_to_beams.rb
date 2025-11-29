class RenameServicesToBeams < ActiveRecord::Migration[8.0]
  def change
    rename_table :services, :beams
    rename_table :requests, :beam_deflections
    rename_table :requests_services, :beam_deflections_beams
    
    rename_column :beam_deflections_beams, :service_id, :beam_id
    rename_column :beam_deflections_beams, :request_id, :beam_deflection_id
  end
end
