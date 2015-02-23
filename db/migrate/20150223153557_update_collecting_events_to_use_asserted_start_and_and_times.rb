class UpdateCollectingEventsToUseAssertedStartAndAndTimes < ActiveRecord::Migration
  def change

    remove_column :collecting_events, :time_start
    remove_column :collecting_events, :time_end

    add_column :collecting_events, :time_start_hour, :integer, limit: 2
    add_column :collecting_events, :time_start_minute, :integer, limit: 2
    add_column :collecting_events, :time_start_second, :integer, limit: 2

    add_column :collecting_events, :time_end_hour, :integer, limit: 2
    add_column :collecting_events, :time_end_minute, :integer, limit: 2
    add_column :collecting_events, :time_end_second, :integer, limit: 2

  end
end
