class AddCompositeUniqToLfbt < ActiveRecord::Migration[7.1]
  def up
    # На всякий: удалим точные дубли (оставляя первую запись)
    execute <<~SQL
      DELETE FROM load_forecasts_beam_types t
      USING load_forecasts_beam_types d
      WHERE t.ctid < d.ctid
        AND t.load_forecast_id = d.load_forecast_id
        AND t.beam_type_id     = d.beam_type_id
        AND COALESCE(t.length_m,0) = COALESCE(d.length_m,0)
        AND COALESCE(t.load_kn_m,0) = COALESCE(d.load_kn_m,0);
    SQL

    add_index :load_forecasts_beam_types,
              [:load_forecast_id, :beam_type_id, :length_m, :load_kn_m],
              unique: true,
              name: :idx_lfbt_unique
  end

  def down
    remove_index :load_forecasts_beam_types, name: :idx_lfbt_unique
  end
end
