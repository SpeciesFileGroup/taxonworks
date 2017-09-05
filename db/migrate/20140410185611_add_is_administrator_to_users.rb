class AddIsAdministratorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_administrator, :boolean
  end
end
