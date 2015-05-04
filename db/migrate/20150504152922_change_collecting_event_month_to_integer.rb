class ChangeCollectingEventMonthToInteger < ActiveRecord::Migration
  def change
    remove_column :collecting_events, :start_date_month, :string
    add_column :collecting_events, :start_date_month, :integer

    remove_column :collecting_events, :end_date_month, :string
    add_column :collecting_events, :end_date_month, :integer
  end
end
