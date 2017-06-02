class AddTempToUser < ActiveRecord::Migration
  def change
    add_column :users, :temp, :string
  end
end
