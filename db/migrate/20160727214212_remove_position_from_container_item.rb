class RemovePositionFromContainerItem < ActiveRecord::Migration
  def change
    remove_column :container_items, :position
  end
end
