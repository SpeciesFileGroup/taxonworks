class RenameGraphToGraphs < ActiveRecord::Migration
  def change
    rename_column :biological_associations_biological_associations_graphs, :biological_association_graph_id, :biological_associations_graph_id
  end
end
