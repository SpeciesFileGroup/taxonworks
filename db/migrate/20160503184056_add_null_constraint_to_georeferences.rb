class AddNullConstraintToGeoreferences < ActiveRecord::Migration
  def change
    change_column_null :georeferences, :collecting_event_id, false
  end
end
