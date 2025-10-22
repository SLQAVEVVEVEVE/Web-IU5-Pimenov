class DropLegacyPairUniqueIndexOnLfbt < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE schemaname = current_schema()
            AND tablename  = 'load_forecasts_beam_types'
            AND indexname  = 'idx_dr_items_uniq'
        ) THEN
          DROP INDEX IF EXISTS idx_dr_items_uniq;
        END IF;
      END $$;
    SQL
  end

  def down
    # Восстанавливать старую уникальность не нужно.
    # Если очень надо — раскомментируй:
    # add_index :load_forecasts_beam_types, [:load_forecast_id, :beam_type_id],
    #           unique: true, name: :idx_dr_items_uniq
  end
end
