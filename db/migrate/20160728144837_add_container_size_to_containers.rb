class AddContainerSizeToContainers < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :size_x, :integer
    add_column :containers, :size_y, :integer
    add_column :containers, :size_z, :integer
  end
end
