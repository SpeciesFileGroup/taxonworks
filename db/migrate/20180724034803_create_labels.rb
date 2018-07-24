class CreateLabels < ActiveRecord::Migration[5.1]
  def change
    create_table :labels do |t|
      t.string :text
      t.integer :total
      t.string :style
      t.string :object_global_id
      t.boolean :is_copy_edited
      t.boolean :is_printed
      t.references :project, foreign_key: true
      

      t.timestamps
    end
  end
end
