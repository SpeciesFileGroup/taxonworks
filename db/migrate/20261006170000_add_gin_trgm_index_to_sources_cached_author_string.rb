class AddGinTrgmIndexToSourcesCachedAuthorString < ActiveRecord::Migration[8.1]
  def change
    add_index :sources, :cached_author_string,
      using: :gin,
      opclass: :gin_trgm_ops,
      name: 'src_cached_author_string_gin_trgm'
  end
end
