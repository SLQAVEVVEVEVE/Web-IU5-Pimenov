class RenameRequestsToLoadForecasts < ActiveRecord::Migration[7.1]
  def up
    # 1) Переименовать таблицы
    rename_table :deflection_requests, :load_forecasts
    rename_table :deflection_request_beam_types, :load_forecasts_beam_types

    # 2) Переименовать FK колонку в m-m
    if column_exists?(:load_forecasts_beam_types, :deflection_request_id)
      rename_column :load_forecasts_beam_types, :deflection_request_id, :load_forecast_id
    end

    # 3) Переименовать (пересоздать) частичный уникальный индекс черновиков
    # старый индекс мог называться так:
    execute "DROP INDEX IF EXISTS idx_deflection_requests_one_draft_per_user"
    execute <<~SQL
      CREATE UNIQUE INDEX idx_load_forecasts_one_draft_per_user
        ON load_forecasts (requester_id)
       WHERE status = 0;
    SQL
  end

  def down
    # Откат: возвращаем всё как было (минимально)
    execute "DROP INDEX IF EXISTS idx_load_forecasts_one_draft_per_user"

    rename_column :load_forecasts_beam_types, :load_forecast_id, :deflection_request_id rescue nil
    rename_table  :load_forecasts_beam_types, :deflection_request_beam_types
    rename_table  :load_forecasts,            :deflection_requests

    # старый индекс (если нужен откат)
    execute <<~SQL
      CREATE UNIQUE INDEX idx_deflection_requests_one_draft_per_user
        ON deflection_requests (requester_id)
       WHERE status = 0;
    SQL
  end
end
