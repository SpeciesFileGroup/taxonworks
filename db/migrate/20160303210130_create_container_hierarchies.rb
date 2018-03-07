class CreateContainerHierarchies < ActiveRecord::Migration[4.2]
  def change
    create_table :container_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :container_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name:   'container_anc_desc_idx'

    add_index :container_hierarchies, [:descendant_id],
      name: 'container_desc_idx'
  end
end
