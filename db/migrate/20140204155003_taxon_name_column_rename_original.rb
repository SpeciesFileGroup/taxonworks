class TaxonNameColumnRenameOriginal < ActiveRecord::Migration[4.2]
  def change
    rename_column :taxon_names, :cached_original_name, :cached_original_combination
  end
end
