class RemoveGeographicItemCentroidIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :geographic_items, name: 'idx_centroid'
  end
end
