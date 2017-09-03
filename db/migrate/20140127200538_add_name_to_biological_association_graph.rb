class AddNameToBiologicalAssociationGraph < ActiveRecord::Migration[4.2]
  def change
    add_column :biological_associations_graphs, :name, :string
  end
end
