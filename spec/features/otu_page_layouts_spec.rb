require 'rails_helper'

describe 'OtuPageLayouts', :type => :feature do
  let(:page_title) { 'Otu page layouts' }
  
  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { otu_page_layouts_path }
  end

  describe 'GET /otu_page_layouts' do
    before {
      sign_in_user_and_select_project 
      visit otu_page_layouts_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu page layouts')
    end
  end

end
