class CleanupGeographicAreas2 < ActiveRecord::Migration[4.2]
  def change
    remove_column :geographic_areas, :adm0_a3 
  end
end
