class AddDeletedAtToLoadForecastBeamTypesAgain < ActiveRecord::Migration[8.0]
  def change
    add_column :load_forecasts_beam_types, :deleted_at, :datetime
    add_index :load_forecasts_beam_types, :deleted_at
  end
end
