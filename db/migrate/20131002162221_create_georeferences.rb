class CreateGeoreferences < ActiveRecord::Migration
  def change
    create_table :georeferences do |t|
      t.integer :geographic_item_id
      t.integer :collecting_event_id
      t.decimal :error_radius
      t.decimal :error_depth
      t.integer :error_geographic_item_id
      t.string :type
      t.integer :source_id
      t.integer :position

      t.timestamps
    end
  end
end
