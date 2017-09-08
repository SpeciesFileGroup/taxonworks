class DropBiologicalPropertiesTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :biological_properties
  end
end
