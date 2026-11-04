# Flat (in-plane) rotation is rotation_z; 3D tilts (x, y) are not needed.
class ChangeRotationsOnCompositionItems < ActiveRecord::Migration[8.1]
  def change
    add_column :composition_items, :rotation_z, :float
    remove_column :composition_items, :rotation_x, :float
    remove_column :composition_items, :rotation_y, :float
  end
end
