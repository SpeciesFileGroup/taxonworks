class AddUntranslatedToCachedMapItem < ActiveRecord::Migration[6.1]
  def change
    add_column :cached_map_items, :untranslated, :boolean
  end
end
