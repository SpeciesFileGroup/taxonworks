class AddCachedAuthorToTaxonName < ActiveRecord::Migration[6.1]
  def change
    add_column :taxon_names, :cached_author, :varchar
  end
end
