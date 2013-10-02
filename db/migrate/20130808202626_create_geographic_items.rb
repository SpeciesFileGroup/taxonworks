class CreateGeographicItems < ActiveRecord::Migration
  def change
    create_table :geographic_items do |t|
      t.string :a_name, :geographic => false
      t.point :a_point, :geographic => true, :has_z => true, :has_m => true
      t.line_string :a_simple_line, :geographic => true
      t.line_string :a_complex_line, :geographic => true
      t.line_string :a_linear_ring, :geographic => true
      t.polygon :a_polygon, :geographic => true
      t.multi_point :a_multi_point, :geographic => true, :has_z => true, :has_m => true
      t.multi_line_string :a_multi_line_string, :geographic => true
      t.multi_polygon :a_multi_polygon, :geographic => true
      t.geometry_collection :a_geometry_collection, :geographic => true

      t.timestamps
    end
  end
end
