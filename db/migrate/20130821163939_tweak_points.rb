class TweakPoints < ActiveRecord::Migration
  def change
    remove_columns :geographic_items, :point, :multi_point
    add_column :geographic_items, :point, :point, :geographic => true
    add_column :geographic_items, :multi_point, :multi_point, :geographic => true
  end
end
