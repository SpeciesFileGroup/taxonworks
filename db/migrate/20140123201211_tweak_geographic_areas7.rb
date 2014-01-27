class TweakGeographicAreas7 < ActiveRecord::Migration
  def change

    remove_column :geographic_areas, :ne_geo_item_id
    add_column :geographic_areas, :ne_geo_item_id, :string
    add_column :geographic_areas, :adm0_a3, :string

  end
end
