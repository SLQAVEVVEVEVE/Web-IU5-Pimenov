class EnsureDeflectionRequestStatusDefaults < ActiveRecord::Migration[7.1]
  def change
    change_column_default :deflection_requests, :status, 0
    change_column_null    :deflection_requests, :status, false
  end
end
