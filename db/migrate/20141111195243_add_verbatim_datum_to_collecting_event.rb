class AddVerbatimDatumToCollectingEvent < ActiveRecord::Migration
  def change
    add_column :collecting_events, :verbatim_datum, :string
  end
end
