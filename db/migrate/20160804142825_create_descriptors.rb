class CreateDescriptors < ActiveRecord::Migration
  def change
    create_table :descriptors do |t|
      t.string :name, null: false, index: true
      t.string :short_name, index: true
      t.string :type, null: false
      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :descriptors, :users, column: :created_by_id
    add_foreign_key :descriptors, :users, column: :updated_by_id
  end
end
