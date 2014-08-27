require 'rails_helper'

describe 'CollectionObjects', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { collection_objects_path }
    let(:page_index_name) { 'Collection Objects' }
  end

  describe 'GET /collection_objects' do
    before {
      sign_in_valid_user_and_select_project
      visit collection_objects_path }

    specify 'an index name is present' do
      expect(page).to have_content('Collection Objects')
    end
  end

  describe 'GET /collection_objects/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_collection_object) }
      visit '/collection_objects/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Collection Objects'
    end
  end

  describe 'GET /collection_objects/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_collection_object) }
      all_collection_objects = CollectionObject.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/collection_objects/#{all_collection_objects[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end
  end
end

