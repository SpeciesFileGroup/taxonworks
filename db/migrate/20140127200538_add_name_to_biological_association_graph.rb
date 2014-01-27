class AddNameToBiologicalAssociationGraph < ActiveRecord::Migration
  def change
    add_column :biological_associations_graphs, :name, :string
  end
end
