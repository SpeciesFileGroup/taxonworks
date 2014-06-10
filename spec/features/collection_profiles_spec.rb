require 'spec_helper'

describe 'CollectionProfiles', base_class: CollectionProfile do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /collection_profiles' do
    before { 
      sign_in_valid_user_and_select_project 
      visit collection_profiles_path }
    specify 'an index name is present' do
      expect(page).to have_content('Collection Profiles')
    end
  end
end
