class HardRelaxNullsOnRequestSubjectFields < ActiveRecord::Migration[8.0]
  def up
    # length_m
    if column_exists?(:requests, :length_m)
      # Drop NOT NULL if present
      execute <<~SQL
        ALTER TABLE requests
        ALTER COLUMN length_m DROP NOT NULL;
      SQL
      # Drop default if any
      execute <<~SQL
        ALTER TABLE requests
        ALTER COLUMN length_m DROP DEFAULT;
      SQL
    end

    # udl_kn_m
    if column_exists?(:requests, :udl_kn_m)
      execute <<~SQL
        ALTER TABLE requests
        ALTER COLUMN udl_kn_m DROP NOT NULL;
      SQL
      execute <<~SQL
        ALTER TABLE requests
        ALTER COLUMN udl_kn_m DROP DEFAULT;
      SQL
    end
  end

  def down
    # no-op on purpose to keep spec compliance (subject fields must be nullable)
  end
end
