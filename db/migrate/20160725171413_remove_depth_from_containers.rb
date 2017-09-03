class RemoveDepthFromContainers < ActiveRecord::Migration[4.2]
  def change
    remove_column :containers, :depth
  end
end
