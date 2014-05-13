class CreateGeographicAreasGeographicItems < ActiveRecord::Migration
  def change
    create_table :geographic_areas_geographic_items do |t|
      t.references :geographic_area, index: true
      t.references :geographic_item, index: true
      t.string :data_origin
      t.integer :origin_gid
      t.string :date_valid_from
      t.string :date_valid_to
      t.string :date_valid_origin

      t.timestamps
    end
  end
end
