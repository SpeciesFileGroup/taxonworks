require 'rails_helper'

describe 'PreparationTypes', :type => :feature do
  let(:page_title) { 'Preparation types' }
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

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
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
      click_link('New')
      fill_in('Name', with: 'Flash frozen') 
      fill_in('Definition', with: 'Dipped in dry ice.') 
      click_button('Create Preparation type') 
      expect(page).to have_content("Preparation type 'Flash frozen' was successfully created.")
    end
  end
end

