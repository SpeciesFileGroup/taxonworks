class CreateSledImages < ActiveRecord::Migration[6.0]
  def change
    create_table :sled_images do |t|
      t.references :image, null: false
      t.jsonb :metadata
      t.jsonb :object_layout
      t.integer :cached_total_rows
      t.integer :cached_total_columns
      t.integer :cached_total_collection_objects, null: false, default: 0

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.references :project, index: true, foreign_key: true
      t.timestamps  null: false
    end

    add_foreign_key :sled_images, :users, column: :created_by_id
    add_foreign_key :sled_images, :users, column: :updated_by_id
  end
end
