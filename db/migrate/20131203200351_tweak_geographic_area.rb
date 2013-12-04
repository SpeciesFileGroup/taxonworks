class TweakGeographicArea < ActiveRecord::Migration
  def change

    add_column :geographic_areas, :iso_3166_1_alpha_2, :string
    add_column :geographic_areas, :rgt, :integer
    add_column :geographic_areas, :lft, :integer

  end
end
