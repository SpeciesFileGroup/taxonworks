class RenameColumnInRepositories < ActiveRecord::Migration
  def change
    remove_column :repositories, :is_index_herbarioum_record
    add_column :repositories, :is_index_herbariorum, :boolean
  end
end
