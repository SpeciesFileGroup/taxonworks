class CreateCachedMapItems < ActiveRecord::Migration[6.1]
  def change
    create_table :cached_map_items do |t|
      t.references :otu, null: false
      t.references :geographic_item, null: false
      t.string :type
      t.integer :reference_count
      t.boolean :is_absent
      t.string :level0_geographic_name 
      t.string :level1_geographic_name 
      t.string :level2_geographic_name 
      t.references :project
      t.timestamps
    end

    add_index :cached_map_items, [:otu_id, :geographic_item_id]
  end
end
