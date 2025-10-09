class AddInputsToDeflectionRequestBeamTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :deflection_request_beam_types, :length_m, :decimal
    add_column :deflection_request_beam_types, :load_kn_m, :decimal
  end
end
