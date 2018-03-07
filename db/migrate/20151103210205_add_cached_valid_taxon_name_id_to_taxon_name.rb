class AddCachedValidTaxonNameIdToTaxonName < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :cached_valid_taxon_name_id, :integer
  end
end
