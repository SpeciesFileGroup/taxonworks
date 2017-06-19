class AddEtymologyToTaxonName < ActiveRecord::Migration
  def change
    add_column :taxon_names, :etymology, :text
  end
end
