class DropProjectIdFromGeoTables < ActiveRecord::Migration[4.2]
  def change
    remove_column :geographic_area_types, :project_id
    remove_column :geographic_areas, :project_id
  end
end
