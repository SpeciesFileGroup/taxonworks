require 'rails_helper'

describe 'CollectionObjects', :type => :feature do
  let(:index_path) { collection_objects_path }
  let(:page_index_name) { 'collection objects' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) }
    }

    describe 'GET /collection_objects' do
      before {
        visit collection_objects_path }

      it_behaves_like 'a_data_model_with_standard_index'

      # specify 'an index name is present' do
      #   expect(page).to have_content(page_index_name)
      # end
    end

    describe 'GET /collection_objects/list' do
      before { visit list_collection_objects_path }

      it_behaves_like 'a_data_model_with_standard_list'

      # specify 'that it renders without error' do
      #   expect(page).to have_content 'Listing Collection Objects'
      # end
    end

    describe 'GET /collection_objects/n' do
      before {
        visit collection_object_path(CollectionObject.second) 
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'creating a new collection object' do
    before {
      sign_in_user_and_select_project # logged in and project selected
      visit collection_objects_path # when I visit the collection_objects_path
    }

    specify 'it has a new link' do
      expect(page).to have_link('new')
    end

    specify 'follow the new link & create a new collection object' do
      click_link('new') # when I click the new link
      fill_in 'Total', with: '1' # fill out the total field with 1
      fill_in 'Buffered collecting event', with: 'This is a label.\nAnd another line.' # fill in Buffered collecting event
      click_button 'Create Collection object' # when I click the 'Create Collection object' button
      # then I get the message "Collecting objection was successfully created"
      expect(page).to have_content('Collection object was successfully created.')
    end

  end
end
