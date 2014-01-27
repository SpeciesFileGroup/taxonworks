class RenameBiologicalRelationshipPropretyToType < ActiveRecord::Migration
  def change
    rename_table :biological_relationship_properties, :biological_relationship_types
  end
end
