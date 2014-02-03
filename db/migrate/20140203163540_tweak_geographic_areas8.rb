class TweakGeographicAreas8 < ActiveRecord::Migration
  def change

    add_column :geographic_areas, :neID, :string

  end
end
