class CreateTypeMaterials < ActiveRecord::Migration
  def change
    create_table :type_materials do |t|
      t.integer :protonym_id
      t.integer :biological_object_id
      t.string :type_type
      t.references :source, index: true
      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
