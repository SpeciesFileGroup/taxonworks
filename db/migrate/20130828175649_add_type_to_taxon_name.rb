class AddTypeToTaxonName < ActiveRecord::Migration
  def change
    add_column :taxon_names, :type, :string
  end
end
