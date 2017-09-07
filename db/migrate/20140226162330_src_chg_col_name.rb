class SrcChgColName < ActiveRecord::Migration[4.2]
  def change
    rename_column :sources, :cached_author_year, :cached_author_string
  end
end
