class RenameBiologicalRelationshipPropretyToType < ActiveRecord::Migration[4.2]
  def change
    rename_table :biological_relationship_properties, :biological_relationship_types
  end
end
