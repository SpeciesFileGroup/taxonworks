class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.text :sequence
      t.string :sequence_type
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
