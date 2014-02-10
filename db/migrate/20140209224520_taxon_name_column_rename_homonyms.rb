class TaxonNameColumnRenameHomonyms < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :primary_homonym, :cached_primary_homonym
    rename_column :taxon_names, :secondary_homonym, :cached_secondary_homonym
    rename_column :taxon_names, :primary_homonym_alt, :cached_primary_homonym_alt
    rename_column :taxon_names, :secondary_homonym_alt, :cached_secondary_homonym_alt
  end
end
