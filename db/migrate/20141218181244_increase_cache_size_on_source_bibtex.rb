class IncreaseCacheSizeOnSourceBibtex < ActiveRecord::Migration
  def change
    remove_column :sources, :cached
    add_column :sources, :cached, :text

    remove_column :sources, :cached_author_string
    add_column :sources, :cached_author_string, :text
  end
end
