# OtuPageLayout, OtuPageLayoutSection and TaggedSectionKeyword are unused,
# see #5116. Breaking, data is not migrated.
class DropOtuPageLayouts < ActiveRecord::Migration[8.1]
  def change
    drop_table :tagged_section_keywords
    drop_table :otu_page_layout_sections
    drop_table :otu_page_layouts
  end
end
