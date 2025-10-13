class AddIsDestroyableToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :is_destroyable, :boolean, null: false, default: false
    add_index  :projects, :is_destroyable
  end
end