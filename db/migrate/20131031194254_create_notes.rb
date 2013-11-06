class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :text
      t.integer :note_object_id
      t.string :note_object_type
      t.string :note_object_attribute

      t.timestamps
    end
  end
end
