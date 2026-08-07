class CreateAnatomicalParts < ActiveRecord::Migration[7.2]
  def change
    create_table :anatomical_parts do |t|
      t.text :name, index: true
      t.text :uri, index: true
      t.text :uri_label, index: true
      t.boolean :is_material, index: true
      t.text :cached, index: true
      t.references :project, foreign_key: true, null: false
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps

    end

    add_foreign_key :anatomical_parts, :users, column: :created_by_id
    add_foreign_key :anatomical_parts, :users, column: :updated_by_id
  end
end
