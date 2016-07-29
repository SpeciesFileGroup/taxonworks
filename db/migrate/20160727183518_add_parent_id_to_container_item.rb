class AddParentIdToContainerItem < ActiveRecord::Migration
  def change
    add_column :container_items, :parent_id, :integer
  end
end
