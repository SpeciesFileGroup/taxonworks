class CreateBiologicalAssociations < ActiveRecord::Migration
  def change
    create_table :biological_associations do |t|
      t.references :biological_relationship, index: true
      t.integer :subject_id
      t.string :subject_type
      t.integer :object_id
      t.string :object_type

      t.timestamps
    end
  end
end
