class AddVerbatimDateToCollectingEvent < ActiveRecord::Migration
  def change
    add_column :collecting_events, :verbatim_date, :string
  end
end
