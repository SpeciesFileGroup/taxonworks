require 'rails_helper'

describe 'CollectionObjects', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { collection_objects_path }
    let(:page_index_name) { 'Collection Objects' }
  end

  describe 'GET /collection_objects' do
    before {
      sign_in_user_and_select_project
      visit collection_objects_path }

    specify 'an index name is present' do
      expect(page).to have_content('Collection Objects')
    end
  end

  describe 'GET /collection_objects/list' do
    before do
      sign_in_user_and_select_project
      30.times { factory_girl_create_for_user_and_project(:valid_collection_object, @user, @project) }
      visit list_collection_objects_path
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Collection Objects'
    end
  end

  describe 'GET /collection_objects/n' do
    before {
      sign_in_user_and_select_project
      30.times { factory_girl_create_for_user_and_project(:valid_collection_object, @user, @project) }
      visit collection_object_path(CollectionObject.second) 
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end
  end
end

