class DropLegacyDeflectionTables < ActiveRecord::Migration[7.1]
  def up
    # На всякий случай дроп индексов, если где-то остались
    execute "DROP INDEX IF EXISTS public.ux_deflection_request_beam_type"

    drop_table :deflection_request_beam_types, if_exists: true
    drop_table :deflection_requests,            if_exists: true
  end

  def down
    # Восстанавливать легаси-таблицы не нужно. Если очень надо — тут можно описать recreate.
  end
end
