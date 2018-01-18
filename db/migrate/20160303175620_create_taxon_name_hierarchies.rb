class CreateTaxonNameHierarchies < ActiveRecord::Migration[4.2]
  def change
    create_table :taxon_name_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :taxon_name_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name:   'taxon_name_anc_desc_idx'

    add_index :taxon_name_hierarchies, [:descendant_id],
      name: 'taxon_name_desc_idx'
  end
end
