class CreateGeographicAreas < ActiveRecord::Migration
  def change
    create_table :geographic_areas do |t|
      t.string :name
      t.integer :country_id
      t.integer :state_id
      t.integer :county_id
      t.references :geographic_item, index: true
      t.integer :parent_id
      t.references :geographic_area_type, index: true

      t.timestamps
    end
  end
end
