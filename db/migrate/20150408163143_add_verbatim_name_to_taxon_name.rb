class AddVerbatimNameToTaxonName < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :verbatim_name, :string
  end
end
