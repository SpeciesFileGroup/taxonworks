class AddIsValidColumnToTaxonName < ActiveRecord::Migration[6.0]
  def change
    add_column :taxon_names, :cached_is_valid, :boolean
  end
end
