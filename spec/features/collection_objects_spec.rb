require 'spec_helper'

describe 'CollectionObjects', base_class: CollectionObject do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /collection_objects' do
    before { 
      sign_in_valid_user_and_select_project 
      visit collection_objects_path }
    specify 'an index name is present' do
      expect(page).to have_content('Collection Objects')
    end
  end
end

