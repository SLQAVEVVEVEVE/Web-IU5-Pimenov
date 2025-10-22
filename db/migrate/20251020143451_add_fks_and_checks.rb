# db/migrate/XXXXXXXXXXXX_add_fks_and_checks.rb
class AddFksAndChecks < ActiveRecord::Migration[7.1]
  def up
    # FK для load_forecasts → users
    add_foreign_key :load_forecasts, :users, column: :requester_id, if_not_exists: true
    add_foreign_key :load_forecasts, :users, column: :moderator_id, if_not_exists: true

    # FK для связующей таблицы
    add_foreign_key :load_forecasts_beam_types, :load_forecasts, if_not_exists: true
    add_foreign_key :load_forecasts_beam_types, :beam_types,     if_not_exists: true

    # Усиливаем CHECK: quantity > 0 AND position > 0
    execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_lfbt_quantity_pos') THEN
          ALTER TABLE load_forecasts_beam_types DROP CONSTRAINT chk_lfbt_quantity_pos;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_lfbt_quantity_position_pos') THEN
          ALTER TABLE load_forecasts_beam_types
            ADD CONSTRAINT chk_lfbt_quantity_position_pos
            CHECK (quantity > 0 AND position > 0);
        END IF;
      END $$;
    SQL
  end

  def down
    execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_lfbt_quantity_position_pos') THEN
          ALTER TABLE load_forecasts_beam_types DROP CONSTRAINT chk_lfbt_quantity_position_pos;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_lfbt_quantity_pos') THEN
          ALTER TABLE load_forecasts_beam_types
            ADD CONSTRAINT chk_lfbt_quantity_pos
            CHECK (quantity > 0);
        END IF;
      END $$;
    SQL

    remove_foreign_key :load_forecasts, column: :requester_id if foreign_key_exists?(:load_forecasts, column: :requester_id)
    remove_foreign_key :load_forecasts, column: :moderator_id if foreign_key_exists?(:load_forecasts, column: :moderator_id)
    remove_foreign_key :load_forecasts_beam_types, :load_forecasts if foreign_key_exists?(:load_forecasts_beam_types, :load_forecasts)
    remove_foreign_key :load_forecasts_beam_types, :beam_types     if foreign_key_exists?(:load_forecasts_beam_types, :beam_types)
  end
end
