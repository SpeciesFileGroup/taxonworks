class CreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels do |t|
      t.string :text, null: false
      t.integer :total, null: false
      t.string :style

      t.references :label_object, polymorphic: true, null: false

      t.boolean :is_copy_edited, default: false
      t.boolean :is_printed, default: false

      t.references :project, index: true, foreign_key: true, type: :integer
      t.references :created_by, type: :integer, index: {name: 'labels_created_by_id_index'}, foreign_key: {name: 'labels_created_by_id_fk', to_table: :users}
      t.references :updated_by, type: :integer, index: {name: 'labels_updated_by_id_index'}, foreign_key: {name: 'labels_updated_by_id_fk', to_table: :users}

      t.timestamps
    end
  end
end
