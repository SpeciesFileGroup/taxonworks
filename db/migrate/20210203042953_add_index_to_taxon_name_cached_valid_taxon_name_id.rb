class AddIndexToTaxonNameCachedValidTaxonNameId < ActiveRecord::Migration[6.0]
  def change
    add_index :taxon_names, :cached_valid_taxon_name_id
  end
end
