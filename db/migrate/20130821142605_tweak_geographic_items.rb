class TweakGeographicItems < ActiveRecord::Migration
  def change
    remove_columns :geographic_items, :a_name, :a_simple_line, :a_linear_ring
    rename_column :geographic_items, :a_point, :point
    rename_column :geographic_items, :a_complex_line, :line_string
    rename_column :geographic_items, :a_polygon, :polygon
    rename_column :geographic_items, :a_multi_point, :multi_point
    rename_column :geographic_items, :a_multi_line_string, :multi_line_string
    rename_column :geographic_items, :a_multi_polygon, :multi_polygon
    rename_column :geographic_items, :a_geometry_collection, :geometry_collection
  end
end
