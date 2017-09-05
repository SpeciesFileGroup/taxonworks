class AddIsProjectAdministratorToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_project_administrator, :boolean
  end
end
