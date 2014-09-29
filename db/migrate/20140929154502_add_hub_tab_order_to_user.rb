class AddHubTabOrderToUser < ActiveRecord::Migration


  def change
    add_column :users, :hub_tab_order, :text, array: true, default: [] 
  end
end
