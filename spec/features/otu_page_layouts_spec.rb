require 'spec_helper'

describe 'OtuPageLayouts' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /otu_page_layouts' do
    before { visit otu_page_layouts_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layouts')
    end
  end
end
