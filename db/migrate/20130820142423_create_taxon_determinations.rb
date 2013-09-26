class CreateTaxonDeterminations < ActiveRecord::Migration
  def change
    create_table :taxon_determinations do |t|
      t.integer :biological_collection_object_id
      t.string :verbatim
      t.references :otu, index: true
      t.string :year_made, length: 4
      t.string :month_made, length: 10
      t.string :day_made, length: 2
      t.integer :position
      t.timestamps
    end
  end
end

