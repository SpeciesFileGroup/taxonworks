class CreateCompositionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :composition_items do |t|
      t.string :type, null: false
      t.references :composition, foreign_key: true, index: true
      t.references :composition_item_object, polymorphic: true, index: true
      t.references :parent, foreign_key: { to_table: :composition_items }, index: true

      t.text :text
      t.float :x
      t.float :y
      t.float :z
      t.integer :position

      t.string :svg_view_box
      t.xml :svg_clip
      t.integer :width
      t.integer :height
      t.float :zoom
      t.float :rotation_x
      t.float :rotation_y
      t.float :opacity
      t.boolean :is_visible
      t.integer :total
      t.text :css_style

      t.references :project, foreign_key: true, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_check_constraint :composition_items,
      'opacity >= 0 AND opacity <= 100',
      name: 'composition_item_opacity_check'

    add_foreign_key :composition_items, :users, column: :created_by_id
    add_foreign_key :composition_items, :users, column: :updated_by_id
  end
end
