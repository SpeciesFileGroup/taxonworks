class TweakGeographicAreaTypes < ActiveRecord::Migration[4.2]
  def change

    add_column :geographic_area_types, :created_by_id, :integer, index: true
    add_column :geographic_area_types, :updated_by_id, :integer, index: true
    add_column :geographic_area_types, :project_id, :integer, index: true

  end
end
