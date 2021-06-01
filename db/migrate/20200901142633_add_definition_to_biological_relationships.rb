class AddDefinitionToBiologicalRelationships < ActiveRecord::Migration[6.0]
  def change
    add_column :biological_relationships, :definition, :text
  end
end
