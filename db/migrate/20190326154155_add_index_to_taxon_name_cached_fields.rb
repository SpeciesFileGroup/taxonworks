class AddIndexToTaxonNameCachedFields < ActiveRecord::Migration[5.2]
  def change
    add_index :taxon_names, :cached
    add_index :taxon_names, :cached_original_combination
  end
end
