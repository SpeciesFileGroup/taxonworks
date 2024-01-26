class CreateLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :leads do |t|
      t.integer :parent_id
      t.integer :otu_id
      t.text :text
      t.string :origin_label
      t.text :description
      t.integer :redirect_id
      t.text :link_out
      t.string :link_out_text
      t.integer :position
      t.boolean :is_public
      t.integer :project_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_index :leads, :created_by_id
    add_index :leads, :updated_by_id
  end
end
