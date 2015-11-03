class AddCachedValidTaxonNameIdToTaxonName < ActiveRecord::Migration
  def change
    add_column :taxon_names, :cached_valid_taxon_name_id, :integer
  end
end
