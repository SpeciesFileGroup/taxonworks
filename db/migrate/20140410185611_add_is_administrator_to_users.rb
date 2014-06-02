class AddIsAdministratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_administrator, :boolean
  end
end
