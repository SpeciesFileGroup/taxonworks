require 'rails_helper'

describe 'Sources', type: :feature, group: :sources do
  #Capybara.default_wait_time = 15  # slows down Capybara enough to see what's happening on the form
  let(:page_title) { 'Sources' }
  let(:index_path) { sources_path }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before do
      sign_in_user_and_select_project
      5.times { factory_bot_create_for_user(:valid_source, @user) }
    end

    describe 'GET /sources' do
      before { visit sources_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /sources/list' do
      before { visit list_sources_path }
      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /sources/n' do
      before { visit source_path Source.second }
      it_behaves_like 'a_data_model_with_standard_show'
    end

    context 'editing an existing source' do
      before { visit sources_path }

      specify 'I can find my bibtex source and it has an edit link & I can edit the source', js: true do
        src_bibtex = factory_bot_create_for_user(:soft_valid_bibtex_source_article, @user)

        fill_autocomplete('source_id_for_quick_search_form', with: src_bibtex.title, select: src_bibtex.id)

        expect(page).to have_content('Person, T. (1700) I am a soft valid article. Journal of Test Articles.')
        expect(page).to have_link('Edit')
        click_link('Edit')

        select('article', from: 'source_bibtex_type')

        expect(find_field('Title').value).to eq('I am a soft valid article')
        expect(find_field('Author').value).to eq('Person, Test')
        expect(find_field('Journal').value).to eq('Journal of Test Articles')
        expect(find_field('Year').value).to eq('1700')
        expect(page.has_field?('Verbatim contents')).to be_truthy

        expect(page).to have_selector('#source_verbatim', visible: false)

        fill_in('Author', with: 'Wombat, H.P.')
        fill_in('Year', with: '1920')
        click_button('top_submit') # 'Update Bibtex')
        expect(page).to have_content('Source was successfully updated.')
        expect(page).to have_content('Wombat, H.P. (1920) I am a soft valid article. Journal of Test Articles.')
      end

      specify 'I can find my verbatim source and it has an edit link & I can edit the source', js: true do
        src_verbatim = factory_bot_create_for_user(:valid_source_verbatim, @user)
        tmp = src_verbatim.verbatim

        fill_autocomplete('source_id_for_quick_search_form', with: src_verbatim.cached, select: src_verbatim.id)

        expect(page).to have_content(src_verbatim.cached)
        expect(page).to have_link('Edit')
        click_link('Edit')

        # disabled on edit, so this finder isn't working
        # expect(page.has_checked_field?('source_type_sourceverbatim')).to be_truthy

        expect(find_field('Verbatim').value).to eq(tmp)

        expect(page).to have_selector('#source_author', visible: false)
        expect(page).to have_selector('#source_journal', visible: false)
        expect(page).to have_selector('#source_year', visible: false)
        expect(page).to have_selector('#source_verbatim_contents', visible: false)
        expect(page).to have_selector('#source_verbatim', visible: true)

        fill_in('Verbatim', with: 'New Verbatim source')
        click_button('top_submit') # Update Verbatim')
        expect(page).to have_content('Source was successfully updated.')
        expect(page).to have_content('New Verbatim source')
      end

=begin
    With a bibtex source created by the current user with Roles defined
    when I edit form
    I can add an author from the author list and the cached fields are properly updated
    I can add an editor from the editor list and the cached fields are properly updated
    I can change an author from the author list and the cached fields are properly updated
    I can change an editor from the editor list and the cached fields are properly updated
    I can delete an author from the author list and the cached fields are properly updated
    I can delete an editor from the editor list and the cached fields are properly updated
=end

    end
  end

  context 'as a user create a record' do
    before do 
      sign_in_user_and_select_project
      Source::Bibtex.create!(
        by: @user,
        bibtex_type: 'article',
        title: 'Article Title',
        author: 'Author1',
        year: '2014',
        journal: 'Test journal'
      )
    end 

    context 'later, sign in as administrator' do
      before{ sign_in_with(@administrator.email, @password) }
      let(:src1) {Source.last}

      specify 'who can edit or destroy any source' do
        visit sources_path
        expect(src1.cached).to eq('Author1 (2014) Article Title. <i>Test journal</i>.')
        expect(page).to have_link('Author1 (2014) Article Title. Test journal.')
        expect(page).to have_link('Edit') # there is a recent update list & 'Edit' link is active
        click_link('Author1 (2014) Article Title. Test journal.') # go to show the source not created by admin
        expect(page).to have_link('Edit') # edit & delete are active links
        click_link('Edit') # go to edit page
        expect(find_field('Title').value).to eq('Article Title')
        click_link('top_show') # return to show page
        expect(page).to have_link('Destroy')
      end
    end
  end

  context 'testing new source' do
    before {
      sign_in_user_and_select_project
      visit sources_path
    }
    after {
      click_link('Sign out')
    }

    specify 'can create a new BibTeX source', js: true do
      s = Serial.create!(name: 'My Serial', creator: @user, updater: @user)

      click_link('New')

      # The BibTeX radio button is selected (default).
      expect(page.has_checked_field?('source_type_sourcebibtex')).to be_truthy

      # many fields are present including 'Verbatim contents', but not the 'Verbatim' textbox
      expect(page.has_field?('source_title', type: 'textarea')).to be_truthy
      expect(page.has_field?('source_verbatim_contents', type: 'textarea')).to be_truthy
      expect(page.has_no_field?('source_verbatim', type: 'textarea')).to be_truthy

      select('article', from: 'source_bibtex_type')

      fill_in('Title', with: 'Unicorns and Honey Badgers')
      fill_in('Author', with: 'Wombat, H.P.')
      fill_in('Year', with: '1920')
      fill_autocomplete('serial_id_for_source', with: 'My Serial', select: s.id) # fill out Serial autocomplete with 'My Serial'
      click_button('top_submit') # 'Create Source') # when I click the 'Create Source' button
      expect(page).to have_content("Source::Bibtex successfully created.")
    end

    specify 'can create a new Verbatim source' do
      #Capybara.ignore_hidden_elements = true
      click_link('New')
      choose('source_type_sourceverbatim') # select the Verbatim radio button
      expect(page.has_checked_field?('source_type_sourceverbatim')).to be_truthy
      expect(page.has_field?('source_verbatim', type: 'textarea')).to be_truthy
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
      click_button('top_submit') # Create Source') # when I click the 'Create Source' button
      # I get the message "Source by  'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)' was successfully created."
      expect(page).to have_content("Source::Verbatim successfully created.")
    end

  end




end


