class RenameTablesToMatchDomain < ActiveRecord::Migration[8.0]
  def up
    # Переименовываем таблицы в соответствии с предметной областью
    rename_table :beam_types, :services
    rename_table :load_forecasts, :requests
    rename_table :load_forecasts_beam_types, :request_services

    # Обновляем внешние ключи
    rename_column :request_services, :load_forecast_id, :request_id
    rename_column :request_services, :beam_type_id, :service_id

    # Обновляем индексы
    execute "DROP INDEX IF EXISTS idx_load_forecasts_one_draft_per_user"
    execute "DROP INDEX IF EXISTS index_load_forecasts_beam_types_on_deleted_at"
    execute "DROP INDEX IF EXISTS index_load_forecast_beam_types_on_deleted_at"

    # Создаем новые индексы с правильными именами
    execute <<~SQL
      CREATE UNIQUE INDEX idx_requests_one_draft_per_user
        ON requests (requester_id)
       WHERE status = 0;
    SQL

    add_index :request_services, :deleted_at
    add_index :services, :deleted_at
  end

  def down
    # Откат изменений
    execute "DROP INDEX IF EXISTS idx_requests_one_draft_per_user"
    execute "DROP INDEX IF EXISTS index_request_services_on_deleted_at"
    execute "DROP INDEX IF EXISTS index_services_on_deleted_at"

    rename_column :request_services, :request_id, :load_forecast_id
    rename_column :request_services, :service_id, :beam_type_id

    rename_table :services, :beam_types
    rename_table :requests, :load_forecasts
    rename_table :request_services, :load_forecasts_beam_types

    execute <<~SQL
      CREATE UNIQUE INDEX idx_load_forecasts_one_draft_per_user
        ON load_forecasts (requester_id)
       WHERE status = 0;
    SQL

    add_index :load_forecasts_beam_types, :deleted_at
    add_index :beam_types, :deleted_at
  end
end
