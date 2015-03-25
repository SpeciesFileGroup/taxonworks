require 'rails_helper'

describe 'PreparationTypes', :type => :feature do
  let(:page_index_name) { 'preparation types' }

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { preparation_types_path }
  end

  context 'signed in as user, with some records created' do
    before do
      sign_in_user
      5.times { factory_girl_create_for_user(:valid_preparation_type, @user) }
    end

    describe 'GET /preparation_types' do
      before {
        visit preparation_types_path
      }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /preparation_types/list' do
      before do
        visit list_preparation_types_path
      end

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /preparation_types/n' do
      before do
        visit preparation_type_path(PreparationType.second)
      end

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'creating a new preparation type' do
    before {
      sign_in_user
      visit preparation_types_path
    }

    specify 'I should be able to create a new preparation type' do
      click_link('new') # when I click the new link
      fill_in('Name', with: 'Flash frozen') # fill out the name field with "Flash frozen"
      fill_in('Definition', with: 'Dipped in dry ice.') #fill out the definition field with "Dipped in dry ice."
      click_button('Create Preparation type') # when I click the 'Create Preparation type' button
      # then I get the message "Preparation type 'Flash frozen' " was successfully created"
      expect(page).to have_content("Preparation type 'Flash frozen' was successfully created.")
    end
  end
end

