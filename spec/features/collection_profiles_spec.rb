require 'rails_helper'

describe 'CollectionProfiles', :type => :feature do
  let(:page_index_name) { 'Collection profiles' }
  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { collection_profiles_path }
  end

  describe 'GET /collection_profiles' do
    before { 
      sign_in_user_and_select_project 
      visit collection_profiles_path }
    specify 'an index name is present' do
      expect(page).to have_content(page_index_name)
    end
  end
end
