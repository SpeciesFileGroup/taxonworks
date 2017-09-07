class CreateGeographicAreaTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :geographic_area_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
