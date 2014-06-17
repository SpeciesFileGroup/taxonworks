require 'spec_helper'

describe 'OtuPageLayoutSections' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { otu_page_layout_sections_path }
    let(:page_index_name) { 'Otu Page Layout Sections' }
  end

  describe 'GET /otu_page_layout_sections' do
    before {
      sign_in_user_and_select_project 
      visit otu_page_layout_sections_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layout Sections')
    end
  end
end
