class CleanupGeographicAreas2 < ActiveRecord::Migration
  def change
    remove_column :geographic_areas, :adm0_a3 
  end
end
