class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :type
      t.integer :attribute_subject_id
      t.string :attribute_subject_type
      t.integer :controlled_vocabularly_term_id
      t.string :import_predicate
      t.string :value

      t.timestamps
    end
  end
end
