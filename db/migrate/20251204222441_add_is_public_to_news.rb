class AddIsPublicToNews < ActiveRecord::Migration[7.2]
  def change
    add_column :news, :is_public, :boolean
    add_index :news, :is_public
  end
end
