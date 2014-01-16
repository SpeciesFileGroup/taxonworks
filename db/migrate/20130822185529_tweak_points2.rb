class TweakPoints2 < ActiveRecord::Migration
  def change
    remove_columns :geographic_items, :point,
                                      :line_string,
                                      :polygon,
                                      :multi_point,
                                      :multi_line_string,
                                      :multi_polygon
    add_column :geographic_items, :point, :point, :geographic => true, :has_z => true, :has_m => true
    add_column :geographic_items, :line_string, :line_string, :geographic => true, :has_z => true, :has_m => true
    add_column :geographic_items, :polygon, :polygon, :geographic => true, :has_z => true, :has_m => true
    add_column :geographic_items, :multi_point, :multi_point, :geographic => true, :has_z => true, :has_m => true
    add_column :geographic_items, :multi_line_string, :multi_line_string, :geographic => true, :has_z => true, :has_m => true
    add_column :geographic_items, :multi_polygon, :multi_polygon, :geographic => true, :has_z => true, :has_m => true
  end
end
