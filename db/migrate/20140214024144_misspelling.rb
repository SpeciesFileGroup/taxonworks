class Misspelling < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :cached_misspelling, :boolean
  end
end
