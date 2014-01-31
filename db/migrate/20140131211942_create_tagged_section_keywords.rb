class CreateTaggedSectionKeywords < ActiveRecord::Migration
  def change
    create_table :tagged_section_keywords do |t|
      t.references :otu_page_layout_section, index: true
      t.string :keyword_references
      t.integer :position
      t.integer :created_by_id
      t.integer :updated_by_id
      t.references :project, index: true

      t.timestamps
    end
  end
end
