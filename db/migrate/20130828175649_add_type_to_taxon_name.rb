class AddTypeToTaxonName < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :type, :string
  end
end
