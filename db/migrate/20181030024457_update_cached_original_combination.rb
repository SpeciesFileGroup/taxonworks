class UpdateCachedOriginalCombination < ActiveRecord::Migration[5.2]
  def change
    rename_column :taxon_names, :cached_original_combination, :cached_original_combination_html
    add_column :taxon_names, :cached_original_combination, :string, index: true 
  end
end
