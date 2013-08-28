class RenameTaxonNameRankToTaxonNameRankClass < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :rank, :rank_class
  end
end
