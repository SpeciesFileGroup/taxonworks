class AddNullConstraintToGeoreferences < ActiveRecord::Migration[4.2]
  def change
    change_column_null :georeferences, :collecting_event_id, false
  end
end
