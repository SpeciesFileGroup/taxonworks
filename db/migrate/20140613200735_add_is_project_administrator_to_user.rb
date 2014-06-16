class AddIsProjectAdministratorToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_project_administrator, :boolean
  end
end
