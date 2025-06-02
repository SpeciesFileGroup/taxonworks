class DropOldGeographicItemShapeColumns < ActiveRecord::Migration[7.2]
  def change
    remove_column :geographic_items, :point
    remove_column :geographic_items, :line_string
    remove_column :geographic_items, :polygon
    remove_column :geographic_items, :multi_point
    remove_column :geographic_items, :multi_line_string
    remove_column :geographic_items, :multi_polygon
    remove_column :geographic_items, :geometry_collection
  end
end
