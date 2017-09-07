class AddIndexToTaxonNameRankClass < ActiveRecord::Migration[4.2]
  def change
    add_index :taxon_names, :rank_class
  end
end
