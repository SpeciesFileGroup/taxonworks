class AddContainerSizeToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :size_x, :integer
    add_column :containers, :size_y, :integer
    add_column :containers, :size_z, :integer
  end
end
