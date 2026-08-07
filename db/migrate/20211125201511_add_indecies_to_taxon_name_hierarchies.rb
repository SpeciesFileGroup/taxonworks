class AddIndeciesToTaxonNameHierarchies < ActiveRecord::Migration[6.1]
  def change
    add_index :taxon_name_hierarchies, :ancestor_id
    add_index :taxon_name_hierarchies, [:ancestor_id, :descendant_id]
  end
end
