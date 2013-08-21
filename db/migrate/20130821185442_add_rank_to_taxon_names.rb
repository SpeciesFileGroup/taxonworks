class AddRankToTaxonNames < ActiveRecord::Migration
  def change
    add_column :taxon_names, :rank, :string
  end
end
