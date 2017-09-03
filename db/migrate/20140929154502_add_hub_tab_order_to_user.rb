class AddHubTabOrderToUser < ActiveRecord::Migration[4.2]


  def change
    add_column :users, :hub_tab_order, :text, array: true, default: [] 
  end
end
