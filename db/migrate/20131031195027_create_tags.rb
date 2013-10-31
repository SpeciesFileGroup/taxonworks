class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :keyword, index: true
      t.integer :tag_object_id
      t.string :tag_object_type
      t.string :tag_object_attribute

      t.timestamps
    end
  end
end
