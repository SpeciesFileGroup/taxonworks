class CreateLeadHierarchies < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :lead_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "lead_anc_desc_idx"

    add_index :lead_hierarchies, [:descendant_id],
      name: "lead_desc_idx"
  end
end
