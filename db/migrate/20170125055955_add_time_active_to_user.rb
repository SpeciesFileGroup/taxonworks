class AddTimeActiveToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_active, :integer, default: 0
  end
end
