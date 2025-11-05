# db/migrate/*_relax_nulls_on_requests_subject_fields.rb
class RelaxNullsOnRequestsSubjectFields < ActiveRecord::Migration[8.0]
  def up
    # Remove NOT NULL constraints
    change_column_null :requests, :length_m, true if column_exists?(:requests, :length_m)
    change_column_null :requests, :udl_kn_m, true if column_exists?(:requests, :udl_kn_m)
    change_column_null :requests, :deflection_mm, true if column_exists?(:requests, :deflection_mm)
    change_column_null :requests, :within_norm, true if column_exists?(:requests, :within_norm)

    # Remove any default values that might force non-null values
    if column_exists?(:requests, :length_m)
      change_column_default :requests, :length_m, from: 0, to: nil rescue nil
    end
    
    if column_exists?(:requests, :udl_kn_m)
      change_column_default :requests, :udl_kn_m, from: 0, to: nil rescue nil
    end
  end

  def down
    # No-op safe down; we won't re-add NOT NULL to keep compatibility with the spec
  end
end
