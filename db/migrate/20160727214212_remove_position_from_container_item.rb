class RemovePositionFromContainerItem < ActiveRecord::Migration[4.2]
  def change
    remove_column :container_items, :position
  end
end
