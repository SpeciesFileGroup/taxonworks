class AddIndexToTaxonNameCachedIsValid < ActiveRecord::Migration[6.0]
  def change
    add_index :taxon_names, :cached_is_valid
  end
end
