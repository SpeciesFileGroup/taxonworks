class ModifyCachedFieldsForTaxonName < ActiveRecord::Migration[4.2]
  def change
    rename_column :taxon_names, :cached_name, :cached_html
    add_column :taxon_names, :cached, :string, index: true
  end
end
