class CleanupGeographicAreas < ActiveRecord::Migration[4.2]
  def change
    remove_column :geographic_areas, :gadmID
    remove_column :geographic_areas, :gadm_geo_item_id
    remove_column :geographic_areas, :gadm_valid_from
    remove_column :geographic_areas, :gadm_valid_to
    remove_column :geographic_areas, :neID
    remove_column :geographic_areas, :ne_geo_item_id
    remove_column :geographic_areas, :tdwg_geo_item_id 
    remove_column :geographic_areas, :tdwg_parent_id
  end
end
