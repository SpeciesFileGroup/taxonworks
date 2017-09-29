class AddIndexToSourceCachedFields < ActiveRecord::Migration[5.1]
  def change
    add_index :sources, :cached_author_string
    add_index :sources, :cached_nomenclature_date
    add_index :sources, :cached
  end
end
