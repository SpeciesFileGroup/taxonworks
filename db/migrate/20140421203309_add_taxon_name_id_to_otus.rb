class AddTaxonNameIdToOtus < ActiveRecord::Migration
  def change
    add_column :otus, :taxon_name_id, :integer
    add_index :otus, :taxon_name_id
  end
end
