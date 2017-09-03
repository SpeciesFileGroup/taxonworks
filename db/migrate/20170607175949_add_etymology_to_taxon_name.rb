class AddEtymologyToTaxonName < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :etymology, :text
  end
end
