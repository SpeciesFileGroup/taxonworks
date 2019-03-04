class AllowPersonIdNilInRole < ActiveRecord::Migration[5.2]
  def change
    change_column_null :roles, :person_id, true
  end
end
