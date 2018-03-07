class AddRankToTaxonNames < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :rank, :string
  end
end
