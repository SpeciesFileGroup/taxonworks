class TweakGeographicAreas5 < ActiveRecord::Migration
=begin
  create_table "geographic_areas", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.integer  "state_id"
    t.integer  "county_id"
    t.integer  "geographic_item_id"
    t.integer  "parent_id"
    t.integer  "geographic_area_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "iso_3166_a2"
    t.integer  "rgt"
    t.integer  "lft"
    t.integer  "tdwg_parent_id"
    t.boolean  "iso_verified"
    t.string   "iso_3166_a3"
  end
=end
  def change

    remove_column     :geographic_areas, :iso_verified

    rename_column     :geographic_areas, :country_id, :level0_id
    rename_column     :geographic_areas, :state_id, :level1_id
    rename_column     :geographic_areas, :county_id, :level2_id

    rename_column     :geographic_areas, :geographic_item_id, :gadm_geo_item_id
    add_column        :geographic_areas, :tdwg_geo_item_id, :integer
    add_column        :geographic_areas, :tdwgID, :string

    add_column        :geographic_areas, :gadmID, :integer
    add_column        :geographic_areas, :gadm_valid_from, :string
    add_column        :geographic_areas, :gadm_valid_to, :string

  end
end
