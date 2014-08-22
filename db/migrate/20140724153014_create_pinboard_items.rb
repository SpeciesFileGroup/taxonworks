class CreatePinboardItems < ActiveRecord::Migration
  def change
    create_table :pinboard_items do |t|
      t.references :pinned_object, polymorphic: true, index: true
      t.references :user, index: true
      t.references :project, index: true
      t.integer :position
      t.boolean :is_inserted
      t.boolean :is_cross_project
      t.integer :inserted_count
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
