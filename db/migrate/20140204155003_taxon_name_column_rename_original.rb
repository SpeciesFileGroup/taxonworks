class TaxonNameColumnRenameOriginal < ActiveRecord::Migration
  def change
    rename_column :taxon_names, :cached_original_name, :cached_original_combination
  end
end
