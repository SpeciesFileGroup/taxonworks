require 'rails_helper'

describe 'Serials', :type => :feature do

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { serials_path }
    let(:page_index_name) { 'Serials' }
  end

  describe 'GET /serials' do # list all serials <serials#index>
    before {
      sign_in_user_and_select_project
      visit serials_path }
    specify 'an index name is present' do
      expect(page).to have_content('Serials')
    end
  end

  describe 'GET /serials/:id' do # display a particular serial <serials#show>
    before {
      sign_in_user
      @serial  = factory_girl_create_for_user(:valid_serial, @user)
      visit serial_path(@serial)
    }
    specify 'should see serial attributes' do
      expect(page).to have_content(@serial.name)
    end

  end

  context 'testing new serial' do
    before {
      sign_in_user
      visit serials_path
    }
    specify 'new link is present on serial page' do
      expect(page).to have_link('New') # it has a new link
    end
    specify 'can create a new serial' do
      click_link('New') # when I click the new link

      fill_in('Name', with: 'Journal of Mythical Beasts')
      # fill the first name field with "Journal of Mythical Beasts"
      click_button('Create Serial')
      # when I click the 'Create Serial' button
      expect(page).to have_content('Serial \'Journal of Mythical Beasts\' was successfully created.')
      # then I get the message "Serial 'Journal of Mythical Beasts' was successfully created"
    end
  end
end

