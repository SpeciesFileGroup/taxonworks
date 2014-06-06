require 'spec_helper'

describe "OtuPageLayouts" do
  describe "GET /otu_page_layouts" do
    before { visit otu_page_layouts_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layouts')
    end
  end
end
