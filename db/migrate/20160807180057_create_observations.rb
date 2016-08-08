class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.references :descriptor, index: true, foreign_key: true, null: true
      t.references :otu, index: true, foreign_key: true
      t.references :collection_object, index: true, foreign_key: true
      t.integer :character_state_id, index: true # , foreign_key: true ! TODO: Add FK in CharacterState migration
      t.string :frequency
      t.decimal :continuous_value
      t.string :continuous_unit
      t.integer :sample_n
      t.decimal :sample_min
      t.decimal :sample_max
      t.decimal :sample_median
      t.decimal :sample_mean
      t.string  :sample_units
      t.decimal :sample_standard_deviation
      t.decimal :sample_standard_error
      t.boolean :presence
      t.text :description
      t.string :cached
      t.string :cached_column_label
      t.string :cached_row_label
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :observations, :users, column: :created_by_id
    add_foreign_key :observations, :users, column: :updated_by_id

  end
end
