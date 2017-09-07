class TweakGeographicAreas8 < ActiveRecord::Migration[4.2]
  def change

    add_column :geographic_areas, :neID, :string

  end
end
