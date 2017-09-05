class AddTimeActiveToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :time_active, :integer, default: 0
  end
end
