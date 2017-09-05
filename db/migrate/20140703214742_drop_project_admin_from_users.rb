class DropProjectAdminFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :is_project_administrator
  end
end
