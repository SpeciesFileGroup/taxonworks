class CreateOtuPageLayoutSections < ActiveRecord::Migration
  def change
    create_table :otu_page_layout_sections do |t|
      t.references :otu_page_layout, index: true
      t.string :type
      t.integer :position
      t.references :topic, index: true
      t.string :dynamic_content_class

      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :project_id
      t.timestamps
    end
  end
end
