class TweakGeographicAreas3 < ActiveRecord::Migration
  def change

    rename_column     :geographic_areas, :iso_3166_1_alpha_2, :iso_3166
    remove_column     :geographic_areas, :iso_3166_year
    add_column        :geographic_areas, :iso_source, :string

  end
end
