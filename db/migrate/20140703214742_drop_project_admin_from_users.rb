class DropProjectAdminFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :is_project_administrator
  end
end
