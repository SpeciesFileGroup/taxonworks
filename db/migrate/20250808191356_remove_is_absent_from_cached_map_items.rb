class RemoveIsAbsentFromCachedMapItems < ActiveRecord::Migration[7.2]
  def change
    remove_column :cached_map_items, :is_absent, :boolean
  end
end
