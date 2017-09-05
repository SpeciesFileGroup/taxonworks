class RenameTaxonNameRankToTaxonNameRankClass < ActiveRecord::Migration[4.2]
  def change
    rename_column :taxon_names, :rank, :rank_class
  end
end
