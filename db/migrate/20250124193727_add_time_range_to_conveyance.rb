class AddTimeRangeToConveyance < ActiveRecord::Migration[7.2]
  def change
    add_column :conveyances, :start_time, :numeric
    add_column :conveyances, :end_time, :numeric
  end
end
