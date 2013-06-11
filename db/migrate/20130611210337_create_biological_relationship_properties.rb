class CreateBiologicalRelationshipProperties < ActiveRecord::Migration
  def change
    create_table :biological_relationship_properties do |t|
      t.string :type
      t.references :biological_property_id, index: true
      t.references :biological_relationship_id, index: true

      t.timestamps
    end
  end
end
