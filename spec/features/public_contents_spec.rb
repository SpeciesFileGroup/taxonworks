require 'rails_helper'

describe 'PublicContents', :type => :feature do
  
  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { public_contents_path }
    let(:page_index_name) { 'Public Contents' }
  end

  describe 'GET /public_contents' do
    before {
      sign_in_user_and_select_project 
      visit public_contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Public Contents')
    end
  end
end
