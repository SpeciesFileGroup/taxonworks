class CreateRangedLotCategories < ActiveRecord::Migration
  def change
    create_table :ranged_lot_categories do |t|
      t.string :name
      t.integer :minimum_value
      t.integer :maximum_value

      t.timestamps
    end
  end
end
