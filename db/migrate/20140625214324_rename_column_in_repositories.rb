class RenameColumnInRepositories < ActiveRecord::Migration[4.2]
  def change
    remove_column :repositories, :is_index_herbarioum_record
    add_column :repositories, :is_index_herbariorum, :boolean
  end
end
