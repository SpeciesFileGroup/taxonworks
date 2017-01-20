require 'rails_helper'

describe 'Serials', :type => :feature do
  let(:page_title) { 'Serials' }
  let(:index_path) { serials_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before do
      sign_in_user
      5.times { factory_girl_create_for_user(:valid_serial, @user) }
    end

    describe 'GET /serials' do
      before {
        visit serials_path
      }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /serials/list' do
      before do
        visit list_serials_path
      end

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /serials/n' do
      before do
        visit serial_path(Serial.second)
      end

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'testing new serial' do
    before {
      sign_in_user
      visit serials_path
    }

    specify 'can create a new serial' do
      click_link('New') 
      fill_in('Name', with: 'Journal of Mythical Beasts')
      click_button('Create Serial')
      expect(page).to have_content('Serial \'Journal of Mythical Beasts\' was successfully created.')
    end
  end
end

