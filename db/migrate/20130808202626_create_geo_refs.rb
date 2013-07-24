class CreateGeoRefs < ActiveRecord::Migration
  def change
    create_table :geo_refs do |t|
      t.string :a_name
      t.point :a_point, :geographic => true, :has_z => true
      t.line_string :a_line, :geographic => true
      t.polygon :a_polygon, :geographic => true
      t.multi_polygon :a_multi_polygon, :geographic => true

      t.timestamps
    end
  end
end
