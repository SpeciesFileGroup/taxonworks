class DropBiologicalPropertiesTable < ActiveRecord::Migration
  def change
    drop_table :biological_properties
  end
end
