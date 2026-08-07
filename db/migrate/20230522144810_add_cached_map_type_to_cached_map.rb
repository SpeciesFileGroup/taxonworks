class AddCachedMapTypeToCachedMap < ActiveRecord::Migration[6.1]
  def change 
    add_column :cached_maps, :cached_map_type, :string, null: false
  end
end
