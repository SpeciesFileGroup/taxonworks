class RemoveDepthFromContainers < ActiveRecord::Migration
  def change
    remove_column :containers, :depth
  end
end
