class RemoveNullConstraintsFromTaxonNameCacheFields < ActiveRecord::Migration[5.1]
  def change
    change_column_null :taxon_names, :cached_html, true
  end
end
