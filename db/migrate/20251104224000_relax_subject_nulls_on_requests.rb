class RelaxSubjectNullsOnRequests < ActiveRecord::Migration[8.0]
  def change
    change_column_null :requests, :length_m, true
    change_column_null :requests, :udl_kn_m, true
  end
end
