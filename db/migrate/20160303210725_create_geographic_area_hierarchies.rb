class CreateGeographicAreaHierarchies < ActiveRecord::Migration[4.2]
  def change
    create_table :geographic_area_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :geographic_area_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name:   'geographic_area_anc_desc_idx'

    add_index :geographic_area_hierarchies, [:descendant_id],
      name: 'geographic_area_desc_idx'
  end
end
