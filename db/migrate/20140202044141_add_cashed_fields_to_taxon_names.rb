class AddCashedFieldsToTaxonNames < ActiveRecord::Migration
  def change
    add_column :taxon_names, :cached_original_name, :string, :after => :cached_name
    add_column :taxon_names, :cached_genus_species, :string, :after => :cached_higher_classification
    add_column :taxon_names, :cached_original_genus_species, :string, :after => :cached_genus_species
    add_column :taxon_names, :cached_genus_alternative, :string, :after => :cached_original_genus_species
    add_column :taxon_names, :cached_original_genus_alternative, :string, :after => :cached_genus_alternative
  end
end
