class RenameCollectingEventVerbatimTripCode < ActiveRecord::Migration[7.1]
  def change
    # Also verbatimTripIdentifier
    # FieldIdentifier
    rename_column :collecting_events, :verbatim_trip_identifier, :verbatim_field_number
  end
end
