class CollectingEventSecondsToSecond < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :time_start_seconds
    remove_column :collecting_events, :time_end_seconds

    add_column :collecting_events, :time_start_second, :integer, limit: 2 
    add_column :collecting_events, :time_end_second, :integer, limit: 2
  end
end
