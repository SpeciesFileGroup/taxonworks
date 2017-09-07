class DropAttributesTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :attributes
  end
end
