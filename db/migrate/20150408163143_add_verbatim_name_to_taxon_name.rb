class AddVerbatimNameToTaxonName < ActiveRecord::Migration
  def change
    add_column :taxon_names, :verbatim_name, :string
  end
end
