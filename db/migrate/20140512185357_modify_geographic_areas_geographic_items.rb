class ModifyGeographicAreasGeographicItems < ActiveRecord::Migration[4.2]
  def change
    remove_column :geographic_areas_geographic_items, :date_valid_origin 
  end
end
