require 'rails_helper'
include FormHelper

describe 'Sources', :type => :feature, :group => :sources do
  #Capybara.default_wait_time = 15  # slows down Capybara enough to see what's happening on the form
  let(:page_index_name) { 'sources' }
  let(:index_path) { sources_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before do
      sign_in_user_and_select_project
      5.times { factory_girl_create_for_user(:valid_source, @user) }
    end

    describe 'GET /sources' do
      before {
        visit sources_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /sources/list' do
      before do
        visit list_sources_path
      end

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /sources/n' do
      before {
        visit source_path Source.second
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context "as an administrator, with a different user's records" do
    specify 'can edit or destroy any source' do
      create_source_by_user
      expect(@src1.valid?).to be_truthy
      sign_in_with(@administrator.email, @password) # sign in as administrator
      visit sources_path
      expect(@src1.cached).to eq('Author1 (2014) Article Title. Test journal.')
      expect(page).to have_link('Author1 (2014) Article Title. Test journal.')
      expect(page).to have_link('Edit') # there is a recent update list & 'Edit' link is active
      click_link('Author1 (2014) Article Title. Test journal.') # go to show the source not created by admin
      expect(page).to have_link('Edit') # edit & delete are active links
      click_link('Edit') # go to edit page
      expect(find_field('Title').value).to eq('Article Title')
      click_link('Show') # return to show page
      expect(page).to have_link('Destroy')
    end

  end
  context 'testing new source' do
    before {
      sign_in_user_and_select_project #   logged in and project selected
      visit sources_path } #   when I visit the sources_path

    # Already tested above
    # specify 'new link is present on sources page' do
    #   expect(page).to have_link('new') # it has a new link
    # end
    specify 'can create a new BibTeX source', js: true do
      s = Serial.new(name: 'My Serial', creator: @user, updater: @user)
      expect(s.save).to be_truthy

      click_link('new') #   when I click the new link
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
      fill_in('Year', with: '1920') # fill out Year with '1920'
      fill_autocomplete('serial_id_for_source', with: 'My Serial') # fill out Serial autocomplete with 'My Serial'
      # select the row with 'My Serial'
      click_button('Create Source') # when I click the 'Create Source' button
      # I get the message "Source by 'Wombat, H.P.' was successfully created." (just use the author field only to keep it simple for now).
      expect(page).to have_content("Source by 'Wombat, H.P.' was successfully created.")
    end
    specify 'can create a new Verbatim source' do
      #Capybara.ignore_hidden_elements = true
      click_link('new') #   when I click the new link
      choose('source_type_sourceverbatim') # select the Verbatim radio button
      expect(page.has_checked_field?('source_type_sourceverbatim')).to be_truthy
      expect(page.has_field?('source_verbatim', :type => 'textarea')).to be_truthy
      # TODO when Capybara works better so field('field').visible? is accurate add visibility tests.
      #      expect(page.has_no_field?('source_title', :type => 'textarea')).to be_truthy
      # The 'Verbatim' textbox is the only field available.
      # expect(page.has_no_text?('BibTeX type')).to be_truthy
      # find(:css, "#source_verbatim_contents").should_not be_visible
      # expect(page.has_no_field?('source_title', :type => 'textarea')).to be_truthy
      # expect(page.has_no_field?('source_verbatim_contents', :type => 'textarea')).to be_truthy
      # expect(page.has_field?('source_verbatim', :type => 'textarea')).to be_truthy
      # # enter 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' in the textbox.
      fill_in('source_verbatim', with: 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)')
      click_button('Create Source') # when I click the 'Create Source' button
      # I get the message "Source by  'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created."
      expect(page).to have_content("Source 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created.")
    end

  end

  context 'editing an existing source' do
    before {
      sign_in_user #   logged in
      visit sources_path #   when I visit the sources_path
    }

    specify 'I can find my bibtex source and it has an edit link & I can edit the source', js: true do
      @src_bibtex = factory_girl_create_for_user(:soft_valid_bibtex_source_article, @user)

      fill_autocomplete('source_id_for_quick_search_form', with: @src_bibtex.title)
      click_button('Show')
      expect(page).to have_content('Person, T. (1000) I am a soft valid article. Journal of Test Articles.')
      expect(page).to have_link('Edit')
      click_link('Edit')
      expect(page.has_checked_field?('source_type_sourcebibtex')).to be_truthy
#      expect(find_field('source_bibtex_type').value).to be('article')
      select('article', from: 'source_bibtex_type')

      expect(find_field('Title').value).to eq('I am a soft valid article')
      expect(find_field('Author').value).to eq('Person, Test')
      expect(find_field('Journal').value).to eq('Journal of Test Articles')
      expect(find_field('Year').value).to eq('1000')
      fill_in('Author', with: 'Wombat, H.P.') # change Author to 'Wombat, H.P.'
      fill_in('Year', with: '1920') # change Year to '1920'
      click_button('Update Source')
      expect(page).to have_content("Source was successfully updated.")
      expect(page).to have_content('Wombat, H.P. (1920) I am a soft valid article. Journal of Test Articles.')
    end
    specify 'I can find my verbatim source and it has an edit link & I can edit the source', js: true do
      @src_verbatim = factory_girl_create_for_user(:valid_source_verbatim, @user)
      tmp           = @src_verbatim.verbatim
      fill_autocomplete('source_id_for_quick_search_form', with: @src_verbatim.cached)
      click_button('Show')
      expect(page).to have_content(@src_verbatim.cached)
      expect(page).to have_link('Edit')
      click_link('Edit')
      expect(page.has_checked_field?('source_type_sourceverbatim')).to be_truthy
      expect(page.find_field('Verbatim').value).to eq(tmp)
      # TODO shelved until Matt fixes the coffee script
      #       expect(find_field('Title').value).to eq('I am a soft valid article')
      #       expect(find_field('Author').value).to eq('Person, Test')
      #       expect(find_field('Journal').value).to eq('Journal of Test Articles')
      #       expect(find_field('Year').value).to eq('1000')
      #       fill_in('Author', with: 'Wombat, H.P.') # change Author to 'Wombat, H.P.'
      #       fill_in('Year', with: '1920')  # change Year to '1920'
      fill_in('Verbatim', with: 'New Verbatim source')
      click_button('Update Source')
      expect(page).to have_content('Source was successfully updated.')
      expect(page).to have_content('New Verbatim source')
    end

=begin
    With a source created by the current user
    when I show that source
    there is a 'edit' link
    when I click 'edit'
    then I see the edit form
=end

  end

  def create_source_by_user
    sign_in_user_and_select_project # create record as a non-admin user
    @src1             = Source::Bibtex.new(by: @user)
    @src1.bibtex_type = 'article'
    @src1.title       = 'Article Title'
    @src1.author      = 'Author1'
    @src1.year        = '2014'
    @src1.journal     = 'Test journal'
    @src1.save!
  end
end


