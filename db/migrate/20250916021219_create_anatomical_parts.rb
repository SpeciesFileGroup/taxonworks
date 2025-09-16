class CreateAnatomicalParts < ActiveRecord::Migration[7.2]
  def change
    create_table :anatomical_parts do |t|
      t.text :name
      t.text :uri
      t.text :uri_label
      t.boolean :is_material

      t.timestamps
    end
  end
end
