require 'rails_helper'

describe 'Sources', :type => :feature do

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { sources_path }
    let(:page_index_name) { 'Sources' }
  end

  describe 'GET /sources' do
    before {
      sign_in_user_and_select_project
      visit sources_path }
    specify 'an index name is present' do
      expect(page).to have_content('Sources')
    end
  end

  context 'testing new source' do
    before {
      sign_in_user_and_select_project #   logged in and project selected
      visit sources_path } #   when I visit the sources_path

    specify 'new link is present on sources page' do
      expect(page).to have_link('New') # it has a new link
    end
    specify 'can create a new source' do
      let!(:serial) { FactoryGirl.create(:valid_serial, name: 'My Serial') }

      click_link('New') #   when I click the new link

      fill_in('')
      #   and I fill out Serial with 'My Serial' (make it a ajax selector)
      #   and I select the row with 'My Serial' that is returned
      #   and I fill out Title with 'Unicorns and Honey Badgers'
      #   and I fill out Year with '1920'
      #   and I fill out Author with 'Wombat, H.P.'
      #   when I click the 'Create Source' button
      #   then I get the message "Source by 'Wombat, H.P.' was successfully created." (just use the author field only to keep it simple for now).
    end

  end
end


