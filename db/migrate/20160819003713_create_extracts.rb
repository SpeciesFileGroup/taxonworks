class CreateExtracts < ActiveRecord::Migration
  def change
    create_table :extracts do |t|
      t.decimal :quantity_value, null: false
      t.string :quantity_unit, null: false
      t.decimal :quantity_concentration, null: false
      t.string :verbatim_anatomical_origin, null: false
      t.integer :year_made, null: false
      t.integer :month_made, null: false
      t.integer :day_made, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
