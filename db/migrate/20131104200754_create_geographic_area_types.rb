class CreateGeographicAreaTypes < ActiveRecord::Migration
  def change
    create_table :geographic_area_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
