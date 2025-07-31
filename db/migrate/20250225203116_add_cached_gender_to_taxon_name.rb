class AddCachedGenderToTaxonName < ActiveRecord::Migration[7.2]
  def change
    add_column :taxon_names, :cached_gender, :text
    add_index :taxon_names, :cached_gender
  end
end
