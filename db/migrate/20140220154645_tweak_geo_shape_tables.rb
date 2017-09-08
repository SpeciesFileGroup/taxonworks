class TweakGeoShapeTables < ActiveRecord::Migration[4.2]
  def change

    add_column :geographic_items, :created_by_id, :integer, index: true
    add_column :geographic_items, :updated_by_id, :integer, index: true

    add_column :georeferences, :created_by_id, :integer, index: true
    add_column :georeferences, :updated_by_id, :integer, index: true

  end
end
