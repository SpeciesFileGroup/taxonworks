class CreateOriginRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :origin_relationships do |t|
      t.references :old_object, polymorphic: true, index: true, null: false
      t.references :new_object, polymorphic: true, index: true, null: false
      t.integer :position
      t.integer :created_by_id, index: true, null: false
      t.integer :updated_by_id, index: true, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :origin_relationships, :users, column: :created_by_id 
    add_foreign_key :origin_relationships, :users, column: :updated_by_id

  end

end
