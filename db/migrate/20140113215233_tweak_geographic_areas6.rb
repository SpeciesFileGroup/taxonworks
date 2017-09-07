class TweakGeographicAreas6 < ActiveRecord::Migration[4.2]
  def change

    add_column  :geographic_areas, :ne_geo_item_id, :integer
    add_column  :geographic_areas, :data_origin, :string

  end
end
