class TweakTaxonNames < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :higher_classification, :cached_higher_classification
    add_column :taxon_names, :year_of_publication, :integer
    add_column :taxon_names, :author, :string
  end
end
