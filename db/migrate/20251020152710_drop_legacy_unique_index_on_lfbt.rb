class DropLegacyUniqueIndexOnLfbt < ActiveRecord::Migration[7.1]
  def up
    # старый индекс (от DeflectionRequest), мешающий уникальности по 4 полям
    execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE schemaname = 'public'
            AND indexname  = 'ux_deflection_request_beam_type'
        ) THEN
          DROP INDEX public.ux_deflection_request_beam_type;
        END IF;
      END $$;
    SQL
  end

  def down
    # Восстанавливать не нужно, но если очень надо — можно вернуть прежний двухполеый индекс:
    # add_index :load_forecasts_beam_types, [:load_forecast_id, :beam_type_id],
    #           unique: true, name: :ux_deflection_request_beam_type
  end
end
