require 'spec_helper'

describe "OtuPageLayoutSections" do
  describe "GET /otu_page_layout_sections" do
    before { visit otu_page_layout_sections_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layout Sections')
    end
  end
end
