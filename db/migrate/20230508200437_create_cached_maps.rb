class CreateCachedMaps < ActiveRecord::Migration[6.1]
  def change
    create_table :cached_maps do |t|
      t.references :otu, null: false, index: true
      t.geometry :geometry, geographic: true
      t.integer :reference_count
      t.references :project, null: false

      t.timestamps
    end
  end
end
