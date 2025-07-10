class CreateGazetteerHierarchies < ActiveRecord::Migration[7.1]
  def change
    create_table :gazetteer_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :gazetteer_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "gazetteer_anc_desc_idx"

    add_index :gazetteer_hierarchies, [:descendant_id],
      name: "gazetteer_desc_idx"
  end
end
