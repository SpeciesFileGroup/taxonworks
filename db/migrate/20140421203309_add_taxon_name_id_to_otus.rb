class AddTaxonNameIdToOtus < ActiveRecord::Migration[4.2]
  def change
    add_column :otus, :taxon_name_id, :integer
    add_index :otus, :taxon_name_id
  end
end
