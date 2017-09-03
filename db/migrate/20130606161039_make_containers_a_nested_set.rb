class MakeContainersANestedSet < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :lft, :integer
    add_column :containers, :rgt, :integer
    add_column :containers, :parent_id, :integer
    add_column :containers, :depth, :integer
  end
end
