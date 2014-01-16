class TweakGeographicArea4 < ActiveRecord::Migration
  def change

    rename_column     :geographic_areas, :iso_3166, :iso_3166_a2
    remove_column     :geographic_areas, :iso_source

    # logic is (iso_3166_a2.nil? AND iso_3166_a3.nil?)
    add_column        :geographic_areas, :iso_verified, :boolean
    add_column        :geographic_areas, :iso_3166_a3, :string

  end
end
