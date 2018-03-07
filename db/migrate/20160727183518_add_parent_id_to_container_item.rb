class AddParentIdToContainerItem < ActiveRecord::Migration[4.2]
  def change
    add_column :container_items, :parent_id, :integer
  end
end
