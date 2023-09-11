class AddLayoutToBiologicalAssociationsGraph < ActiveRecord::Migration[6.1]
  def change
    add_column :biological_associations_graphs, :layout, :jsonb
  end
end
