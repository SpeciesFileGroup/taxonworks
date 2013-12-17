class CreateDataAttributes < ActiveRecord::Migration
  def change
    create_table :data_attributes do |t|
      t.string :type
      t.integer :attribute_subject_id
      t.integer :attribute_subject_type
      t.integer :controlled_vocabulary_term_id
      t.string :import_predicate
      t.string :value
      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
