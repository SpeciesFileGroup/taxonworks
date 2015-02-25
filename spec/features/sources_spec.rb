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
      s = Serial.new(name: 'My Serial', creator: @user, updater: @user)
      expect(s.save).to be_truthy

      click_link('New') #   when I click the new link
      expect(page.has_checked_field?('source_type_sourcebibtex')).to be_truthy
      # The BibTeX radio button is selected (default).
      expect(page.has_field?('source_title', :type => 'textarea')).to be_truthy
      expect(page.has_field?('source_verbatim_contents', :type => 'textarea')).to be_truthy
      expect(page.has_no_field?('source_verbatim', :type => 'textarea')).to be_falsey
      # many fields are present including 'Verbatim contents', but not the 'Verbatim' textbox

=begin
        I select 'article' from the Bibtex type drop down list
        and I fill out Title with 'Unicorns and Honey Badgers'
        and I fill out Author with 'Wombat, H.P.'
        and I fill out Year with '1920'
        and I fill out Serial with 'My Serial' (make it a ajax selector)
        and I select the row with 'My Serial' that is returned
       when I click the 'Create Source' button
            then I get the message "Source by 'Wombat, H.P.' was successfully created." (just use the author field only to keep it simple for now).
   when I click the new link
        I select the Verbatim radio button.
choose('person_type_personvetted')
        The 'Verbatim' textbox is the only field available.
         I  enter 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' in the textbox.
         when I click the 'Create Source' button
            then I get the message "Source by  'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created."
=end
    end

  end
end


