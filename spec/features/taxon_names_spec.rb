require 'rails_helper'

describe 'TaxonNames', :type => :feature do
  Capybara.default_wait_time = 5

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { taxon_names_path }
    let(:page_index_name) { 'Taxon Names' }
  end

  describe 'GET /taxon_names' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path }

    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end

  context 'signed in as a user, with some records created' do
    let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }
    before {
      sign_in_user_and_select_project
      5.times {
        FactoryGirl.create(:iczn_family, user_project_attributes(@user, @project).merge(parent: p, source: nil))
      }
    }

    describe 'GET /taxon_names/list' do
      before do
        visit list_taxon_names_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Taxon Names'
      end
    end

    describe 'GET /taxon_names/n' do
      before {
        visit taxon_name_path(TaxonName.second)
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end
    end
  end

  context 'new link is present on taxon names page' do
    before { sign_in_user_and_select_project }

    specify 'new link is present' do
      visit taxon_names_path # when I visit the taxon_names_path
      expect(page).to have_link('New') # it has a new link
    end
  end

  context 'creating a new TaxonName' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path # when I visit the taxon_names_path
    }
    specify 'testing new TaxonName', js: true do
      click_link('New') # when I click the new link

      fill_in 'Name', with: 'Fooidae' # and I fill out the name field with "Fooidae"
      # and I select 'family (ICZN)' from the Rank select *
      select('family (ICZN)', :from => 'taxon_name_rank_class')

=begin
  none of the following worked
      #find('Parent')
      #find('mx-autocomplete ajaxPicker ui-autocomplete-input')
      #find('Enter a search for Taxon_names')
      # find('find and select taxon_names')
      #find('taxon_name_parent_id')
      # find('taxon_name[parent_id]')
      # find('ui-id-1')

      query =  'root'
      find('taxon_name[parent_id]').native.send_keys(*query.chars)
=end
=begin
      parent = find_by_id('parent_id_for_name')

      # trigger the auto-complete
      # fill_in 'Enter a search for Taxon_names', with: 'root'
      # find_by_id('parent_id_for_name').native.send_key
      parent.native.send_key 'r'
      parent.native.send_key 'o'
      parent.native.send_key 'o'
      parent.native.send_key 't'
     sleep 5 # so the drop down list has time to load
=end
      fill_in "Enter a search for Taxon_names", :with => "root"
      choose_autocomplete_result "Root (nomenclatural rank)", "#Enter a search for Taxon_names"

      # Capybara::ElementNotFound: Unable to find select box "taxon_name_parent_id"
      # select('79251', :from =>'taxon_name_parent_id') # and I select "Root (nomenclatural rank)" in the ajax dropdown *

      #ui-id-1 "ui-autocomplete ui-front ui-menu ui-widget ui-widget-content"
      page.execute_script " $('li.ui-autocomplete').trigger('mouseenter').click(); "

      click_button 'Create Taxon name' # when I click the 'Create Taxon name' button
      # then I get the message "Taxon name 'Foodiae' was successfully created"
      expect(page).to have_content('Taxon name was successfully created.')
    end
  end

  def choose_autocomplete_result(item_text, input_selector="input[data-autocomplete]")
    page.execute_script %Q{ $('#{input_selector}').trigger("focus") }
    page.execute_script %Q{ $('#{input_selector}').trigger("keydown") }
    # Set up a selector, wait for it to appear on the page, then use it.
    sleep 3
    item_selector = "ul.ui-autocomplete li.ui-menu-item a:contains('#{item_text}')"
    page.should have_selector item_selector
    page.execute_script %Q{ $("#{item_selector}").trigger("mouseenter").trigger("click"); }
  end
end






