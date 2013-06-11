class AddBiologicalAssociationGraphIdToBiologicalAssociations < ActiveRecord::Migration
  def change
    add_column :biological_associations, :biological_associations_graph_id, :integer
  end
end
