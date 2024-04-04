class CreateLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :leads do |t|
      t.references :parent, foreign_key: { to_table: :leads }
      t.references :otu, foreign_key: true
      t.text :text, index: true
      t.string :origin_label
      t.text :description
      t.references :redirect, foreign_key: { to_table: :leads }
      t.text :link_out
      t.string :link_out_text
      t.integer :position, index: true
      t.boolean :is_public
      t.references :project, foreign_key: true, null: false

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
