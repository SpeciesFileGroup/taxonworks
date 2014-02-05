class TaxonNameColumnRename < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :cached_genus_species, :secondary_homonym
    rename_column :taxon_names, :cached_original_genus_species, :primary_homonym
    rename_column :taxon_names, :cached_genus_alternative, :secondary_homonym_alt
    rename_column :taxon_names, :cached_original_genus_alternative, :primary_homonym_alt
  end
end
