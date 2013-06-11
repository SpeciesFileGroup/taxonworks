class CreateBiologicalAssociationsGraphs < ActiveRecord::Migration
  def change
    create_table :biological_associations_graphs do |t|

      t.timestamps
    end
  end
end
