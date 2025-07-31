class CreateFieldOccurrences < ActiveRecord::Migration[6.1]
  def change
    create_table :field_occurrences do |t|
      t.integer :total, null: false
      t.references :collecting_event, foreign_key: true, null: false, index: true
      t.references :ranged_lot_category, foreign_key: true, index: true
      t.boolean :is_absent, index: true

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps
    end

    add_foreign_key :field_occurrences, :users, column: :created_by_id
    add_foreign_key :field_occurrences, :users, column: :updated_by_id

  end
end
