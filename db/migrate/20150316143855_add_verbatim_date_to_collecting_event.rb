class AddVerbatimDateToCollectingEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :collecting_events, :verbatim_date, :string
  end
end
