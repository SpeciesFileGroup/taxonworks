class CreateAttribution < ActiveRecord::Migration[5.1]
  def change
    create_table :attribution do |t|
      t.references :attribution_object, polymorphic: true, null: false, index: {name: 'attribution_object_index'}
      t.integer :copyright_year
      t.string :license

      t.references :project, null: false, foreign_key: true, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      
      t.timestamps
    end

    add_index :attribution, :attribution_object_type, name: 'attr_obj_type_index'
    add_index :attribution, :attribution_object_id, name: 'attr_obj_id_index'

    add_foreign_key :attribution, :users, column: :created_by_id
    add_foreign_key :attribution, :users, column: :updated_by_id
  end
end
