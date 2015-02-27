require 'rails_helper'
include FormHelper

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
    specify 'can create a new BibTeX source', js: true do
      s = Serial.new(name: 'My Serial', creator: @user, updater: @user)
      expect(s.save).to be_truthy

      click_link('New') #   when I click the new link
      # The BibTeX radio button is selected (default).
      expect(page.has_checked_field?('source_type_sourcebibtex')).to be_truthy

      # many fields are present including 'Verbatim contents', but not the 'Verbatim' textbox
      expect(page.has_field?('source_title', :type => 'textarea')).to be_truthy
      expect(page.has_field?('source_verbatim_contents', :type => 'textarea')).to be_truthy
      expect(page.has_no_field?('source_verbatim', :type => 'textarea')).to be_truthy

      # I select 'article' from the Bibtex type drop down list
      select('article', from: 'source_bibtex_type')

      fill_in('Title', with: 'Unicorns and Honey Badgers') # fill out Title with 'Unicorns and Honey Badgers'
      fill_in('Author', with: 'Wombat, H.P.') # fill out Author with 'Wombat, H.P.'
      fill_in('Year', with: '1920')  # fill out Year with '1920'
      fill_autocomplete('serial_id_for_source', with: 'My Serial') # fill out Serial autocomplete with 'My Serial'
      # select the row with 'My Serial'
      click_button('Create Source') # when I click the 'Create Source' button
      # I get the message "Source by 'Wombat, H.P.' was successfully created." (just use the author field only to keep it simple for now).
      expect(page).to have_content("Source by 'Wombat, H.P.' was successfully created.")
    end
    specify 'can create a new Verbatim source' do
      click_link('New') #   when I click the new link
      choose('source_type_sourceverbatim') # select the Verbatim radio button
      # The 'Verbatim' textbox is the only field available.
      # expect(page.has_no_text?('BibTeX type')).to be_truthy
      # find(:css, "#source_verbatim_contents").should_not be_visible
      # expect(page.has_no_field?('source_title', :type => 'textarea')).to be_truthy
      # expect(page.has_no_field?('source_verbatim_contents', :type => 'textarea')).to be_truthy
      # expect(page.has_field?('source_verbatim', :type => 'textarea')).to be_truthy
      # # enter 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' in the textbox.
      fill_in('source_verbatim', with:'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)')
      click_button('Create Source') # when I click the 'Create Source' button
      # I get the message "Source by  'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created."
      expect(page).to have_content("Source 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created.")
    end

  end
end


