class ModifyGeographicAreasGeographicItems < ActiveRecord::Migration
  def change
    remove_column :geographic_areas_geographic_items, :date_valid_origin 
  end
end
