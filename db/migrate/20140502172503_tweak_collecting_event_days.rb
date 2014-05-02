class TweakCollectingEventDays < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :start_date_day
    remove_column :collecting_events, :end_date_day
    add_column :collecting_events, :start_date_day, :integer, length: 2
    add_column :collecting_events, :end_date_day, :integer, length: 2
  end
end
