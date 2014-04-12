class AddIsProjectAdministratorToProjectMembers < ActiveRecord::Migration
  def change
    add_column :project_members, :is_project_administrator, :boolean
  end
end
