class CreateBiologicalAssociationsGraphs < ActiveRecord::Migration[4.2]
  def change
    create_table :biological_associations_graphs do |t|

      t.timestamps
    end
  end
end
