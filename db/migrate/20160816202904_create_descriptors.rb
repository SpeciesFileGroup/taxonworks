class CreateDescriptors < ActiveRecord::Migration
  def change
    create_table :descriptors do |t|
      t.integer :descriptor_id, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
