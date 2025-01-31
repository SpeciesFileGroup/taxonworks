class AddTimeRangeToConveyance < ActiveRecord::Migration[7.2]
  def change
    add_column :conveyances, :start_time, :integer
    add_column :conveyances, :end_time, :integer
  end
end
