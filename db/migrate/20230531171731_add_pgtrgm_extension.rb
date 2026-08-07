class AddPgtrgmExtension < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pg_trgm'
    enable_extension 'btree_gin'
  end
end
