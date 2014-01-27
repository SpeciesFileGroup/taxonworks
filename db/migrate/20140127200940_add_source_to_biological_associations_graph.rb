class AddSourceToBiologicalAssociationsGraph < ActiveRecord::Migration
  def change
    add_reference :biological_associations_graphs, :source, index: true
  end
end
