class TweakCollectingEvents < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :start_date_year
    add_column :collecting_events, :start_date_year, :integer, length: 4

    remove_column :collecting_events, :end_date_year
    add_column :collecting_events, :end_date_year, :integer, length: 4 
  end
end
