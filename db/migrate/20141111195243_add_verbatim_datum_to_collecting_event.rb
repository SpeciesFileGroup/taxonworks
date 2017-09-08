class AddVerbatimDatumToCollectingEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :collecting_events, :verbatim_datum, :string
  end
end
