class ExpandTaxonNameCachedColumnNames < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :cached_primary_homonym_alt, :cached_primary_homonym_alternative_spelling
    rename_column :taxon_names, :cached_secondary_homonym_alt, :cached_secondary_homonym_alternative_spelling
  end
end
