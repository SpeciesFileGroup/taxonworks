class AddSpacialDispositionToContainerItems < ActiveRecord::Migration
  def change
    add_column :container_items, :disposition_x, :integer
    add_column :container_items, :disposition_y, :integer
    add_column :container_items, :disposition_z, :integer
  end
end
