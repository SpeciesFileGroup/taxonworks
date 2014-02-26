class Misspelling < ActiveRecord::Migration
  def change
    add_column :taxon_names, :cached_misspelling, :boolean
  end
end
