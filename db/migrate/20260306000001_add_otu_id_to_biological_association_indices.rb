class AddOtuIdToBiologicalAssociationIndices < ActiveRecord::Migration[8.1]
  def change
    add_column :biological_association_indices, :subject_otu_id, :integer
    add_column :biological_association_indices, :object_otu_id, :integer

    add_index :biological_association_indices, :subject_otu_id
    add_index :biological_association_indices, :object_otu_id
  end
end
