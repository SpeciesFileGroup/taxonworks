class AddIndexToGeographicAreasGeographicItemDataOrigin < ActiveRecord::Migration[6.1]
  def change
    add_index :geographic_areas_geographic_items, :data_origin
  end
end
