class TweakGeoShapeTables < ActiveRecord::Migration
  def change

    add_column :geographic_items, :created_by_id, :integer, index: true
    add_column :geographic_items, :updated_by_id, :integer, index: true

    add_column :georeferences, :created_by_id, :integer, index: true
    add_column :georeferences, :updated_by_id, :integer, index: true

  end
end
