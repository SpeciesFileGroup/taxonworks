class AddInvertedNameToBiologicalRelationship < ActiveRecord::Migration[5.1]
  def change
    add_column :biological_relationships, :inverted_name, :string
  end
end
