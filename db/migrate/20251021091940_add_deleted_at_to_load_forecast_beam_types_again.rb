class AddDeletedAtToLoadForecastBeamTypesAgain < ActiveRecord::Migration[8.0]
  def change
    add_column :load_forecast_beam_types_agains, :deleted_at, :datetime
    add_index :load_forecast_beam_types_agains, :deleted_at
  end
end
