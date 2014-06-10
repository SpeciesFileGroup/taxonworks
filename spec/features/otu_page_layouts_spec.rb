require 'spec_helper'

describe 'OtuPageLayouts', base_class: OtuPageLayout do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /otu_page_layouts' do
    before {
      sign_in_valid_user_and_select_project 
      visit otu_page_layouts_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layouts')
    end
  end
end
