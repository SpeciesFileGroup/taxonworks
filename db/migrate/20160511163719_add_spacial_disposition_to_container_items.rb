class AddSpacialDispositionToContainerItems < ActiveRecord::Migration[4.2]
  def change
    add_column :container_items, :disposition_x, :integer
    add_column :container_items, :disposition_y, :integer
    add_column :container_items, :disposition_z, :integer
  end
end
