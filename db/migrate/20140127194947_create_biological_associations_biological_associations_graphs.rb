class CreateBiologicalAssociationsBiologicalAssociationsGraphs < ActiveRecord::Migration
  def change
    create_table :biological_associations_biological_associations_graphs do |t|
      t.references :biological_association_graph # TODO: add migration with index names 
      t.references :biological_association       # index names too long, rebuild

      t.timestamps
    end
  end
end
