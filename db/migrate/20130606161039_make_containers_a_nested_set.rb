class MakeContainersANestedSet < ActiveRecord::Migration
  def change
    add_column :containers, :lft, :integer
    add_column :containers, :rgt, :integer
    add_column :containers, :parent_id, :integer
    add_column :containers, :depth, :integer
  end
end
