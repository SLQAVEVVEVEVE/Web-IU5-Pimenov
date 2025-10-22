class TightenNullsDefaultsAndIndexes < ActiveRecord::Migration[7.1]
  def up
    # =========================
    # USERS
    # =========================
    change_column_null    :users, :email,           false
    add_index             :users, :email, unique: true, name: :idx_users_email_unique
    change_column_null    :users, :password_digest, false
    change_column_default :users, :is_moderator,    from: nil, to: false
    change_column_null    :users, :is_moderator,    false

    # =========================
    # BEAM_TYPES
    # =========================
    change_column_null    :beam_types, :name,           false
    change_column_null    :beam_types, :material,       false
    change_column_null    :beam_types, :elasticity_gpa, false
    change_column_null    :beam_types, :norm,           false
    change_column_default :beam_types, :archived,       from: nil, to: false
    change_column_null    :beam_types, :archived,       false
    # image_key и прочие — остаются nullable

    # =========================
    # LOAD_FORECASTS (бывш. deflection_requests)
    # =========================
    change_column_default :load_forecasts, :status, from: nil, to: 0
    change_column_null    :load_forecasts, :status, false
    change_column_null    :load_forecasts, :requester_id, false

    # поля по теме — nullable по требованию задания
    change_column_null :load_forecasts, :result_mm,    true
    change_column_null :load_forecasts, :formed_at,    true
    change_column_null :load_forecasts, :completed_at, true

    # moderator_id мог отсутствовать в старой схеме — создаём аккуратно
    unless column_exists?(:load_forecasts, :moderator_id)
      add_column :load_forecasts, :moderator_id, :bigint
      add_index  :load_forecasts, :moderator_id, name: :idx_load_forecasts_moderator_id
      # при желании FK:
      # add_foreign_key :load_forecasts, :users, column: :moderator_id
    end
    # он остаётся nullable
    change_column_null :load_forecasts, :moderator_id, true

    # =========================
    # LOAD_FORECASTS_BEAM_TYPES (m-m)
    # =========================

    # --- БЭКОФИЛ ДАННЫХ ПЕРЕД NOT NULL ---

    # 1) quantity: ставим 1 там, где NULL
    execute <<~SQL
      UPDATE load_forecasts_beam_types
         SET quantity = 1
       WHERE quantity IS NULL;
    SQL

    # 2) position: проставим порядковые номера в рамках каждой заявки
    #    только там, где position IS NULL
    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               ROW_NUMBER() OVER (PARTITION BY load_forecast_id ORDER BY id) AS rn
          FROM load_forecasts_beam_types
         WHERE position IS NULL
      )
      UPDATE load_forecasts_beam_types t
         SET position = r.rn
        FROM ranked r
       WHERE t.id = r.id;
    SQL

    # Теперь можно вешать NOT NULL / DEFAULT и CHECK

    change_column_null    :load_forecasts_beam_types, :load_forecast_id, false
    change_column_null    :load_forecasts_beam_types, :beam_type_id,     false

    change_column_default :load_forecasts_beam_types, :quantity, from: nil, to: 1
    change_column_null    :load_forecasts_beam_types, :quantity, false

    change_column_null    :load_forecasts_beam_types, :position, false

    # CHECK на положительное количество
    execute <<~SQL
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
            FROM pg_constraint
           WHERE conname = 'chk_lfbt_quantity_pos'
        ) THEN
          ALTER TABLE load_forecasts_beam_types
            ADD CONSTRAINT chk_lfbt_quantity_pos
            CHECK (quantity > 0);
        END IF;
      END $$;
    SQL
  end

  def down
    # Можно откатить только то, что точно безопасно
    execute "ALTER TABLE load_forecasts_beam_types DROP CONSTRAINT IF EXISTS chk_lfbt_quantity_pos" rescue nil
    remove_index :users, name: :idx_users_email_unique rescue nil
    remove_index :load_forecasts, name: :idx_load_forecasts_moderator_id rescue nil
    remove_column :load_forecasts, :moderator_id rescue nil

    # Остальные изменения (NOT NULL / DEFAULT) обратимо опускать не обязательно,
    # но при желании можно дописать.
  end
end
