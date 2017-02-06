class AddIndexToTaxonNameRankClass < ActiveRecord::Migration
  def change
    add_index :taxon_names, :rank_class
  end
end
