class AddSourceToBiologicalAssociationsGraph < ActiveRecord::Migration[4.2]
  def change
    add_reference :biological_associations_graphs, :source, index: true
  end
end
