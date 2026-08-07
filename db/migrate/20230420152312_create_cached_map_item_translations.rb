class CreateCachedMapItemTranslations < ActiveRecord::Migration[6.1]
  def change
    create_table :cached_map_item_translations do |t|
      t.references :geographic_item, foreign_key: true, index: {name: :cmgit_gi}
      t.references :translated_geographic_item, foreign_key: {to_table: :geographic_items}, index: {name: :cmgit_tgi}
      t.string :cached_map_type, index: {name: :cmgit_cmt}

      t.timestamps
    end
    
    add_index :cached_map_item_translations, [:geographic_item_id, :translated_geographic_item_id, :cached_map_type], unique: true, name: :cmgit_translation

  end
end

