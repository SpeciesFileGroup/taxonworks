require 'rails_helper'
include FormHelper

describe 'TaxonNames', :type => :feature do
  # Capybara.default_wait_time = 15 # change to 15 to see what's happening on form
  
  let(:page_index_name) { 'taxon names' }
  let(:index_path) { taxon_names_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }
    before {
      sign_in_user_and_select_project
      5.times {
        FactoryGirl.create(:iczn_family, user_project_attributes(@user, @project).merge(parent: p, source: nil))
      }
    }

    describe 'GET /taxon_names' do
    before {
      visit taxon_names_path }

    it_behaves_like 'a_data_model_with_standard_index'
  end

    describe 'GET /taxon_names/list' do
      before do
        visit list_taxon_names_path
      end

      it_behaves_like 'a_data_model_with_standard_list'
    end

    describe 'GET /taxon_names/n' do
      before {
        visit taxon_name_path(TaxonName.second)
      }

       it_behaves_like 'a_data_model_with_standard_show'
    end
  end

  context 'new link is present on taxon names page' do
    before { sign_in_user_and_select_project }

    specify 'new link is present' do
      visit taxon_names_path # when I visit the taxon_names_path
      expect(page).to have_link('new') # it has a new link
    end
  end

  context 'creating a new TaxonName' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path # when I visit the taxon_names_path
      FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil))
    }
    specify 'testing new TaxonName', js: true do
      click_link('new') # when I click the new link

      fill_in('Name', with: 'Fooidae') # and I fill out the name field with "Fooidae"
      # and I select 'family (ICZN)' from the Rank select *
      select('family (ICZN)', from: 'taxon_name_rank_class')

      fill_autocomplete('parent_id_for_name', with: 'root')

      click_button('Create Taxon name') # when I click the 'Create Taxon name' button
      # then I get the message "Taxon name 'Foodiae' was successfully created."
      expect(page).to have_content("Taxon name 'Fooidae' was successfully created.")
    end
  end

  context 'editing an original combination' do
    before {
      sign_in_user_and_select_project
      # create the parent genera :
      # With a species created (you'll need a genus 'Aus', family, root)
      # With a different genus ('Bus') created under the same family
      @root    = FactoryGirl.create(:root_taxon_name,
                                    user_project_attributes(@user,
                                                            @project).merge(source:     nil))
      @family    = Protonym.new(user_project_attributes(@user,
                                                        @project).merge(parent:     @root,
                                                                        name:       'Rootidae',
                                                                        rank_class: Ranks.lookup(:iczn, 'Family')))
      @family.save
      @genus_a = Protonym.new(user_project_attributes(@user,
                                                      @project).merge(parent:     @family,
                                                                      name:       'Aus',
                                                                      rank_class: Ranks.lookup(:iczn, 'Genus')))
      @genus_a.save
      @genus_b = Protonym.new(user_project_attributes(@user,
                                                      @project).merge(parent:     @family,
                                                                      name:       'Bus',
                                                                      rank_class: Ranks.lookup(:iczn, 'Genus')))
      @genus_b.save
      visit taxon_names_path # when I visit the taxon_names_path
    }
    specify 'change the original combination of a species to a different genus', js: true do
      # create the original combination Note: couldn't figure out how to do it directly so just used the web interface
      click_link('new')
      fill_in('Name', with: 'specius')
      select('species (ICZN)', from: 'taxon_name_rank_class')
      fill_autocomplete('parent_id_for_name', with: 'Aus', select: 'Aus')
      click_button('Create Taxon name')
      expect(page).to have_content("Taxon name 'specius' was successfully created.")
      # Note that we're now on the show page for species1 # When I show that species
      expect(page).to have_content('Cached name: Aus specius')
      expect(page.has_content?('Cached original combination: Aus specius')).to be_falsey
      expect(page).to have_link('Edit original combination')  # There is an 'Edit original combination link'
      # click_link('Edit original combination') # When I click that link
      # page.find_link('Edit original combination').click
      # above not working for an unknown reason (see
      # http://stackoverflow.com/questions/6693993/capybara-with-selenium-webdriver-click-link-does-not-work-when-link-text-has-lin )
      # link = find_link('Edit original combination')
      # #link.native.send_keys([:return])
      # link.click
      page.find_link('Edit original combination').click
      expect(page).to have_content('Editing original combination for Aus specius')
      fill_autocomplete('subject_taxon_name_id_for_tn_rel_0', with: "Aus",
                        select: 'Aus (genus, parent Rootidae)')
      # Set the original combination for the first time: select 'Aus' for the original genus ajax select
      # Had to add the '\r' to get the auto select to correctly select Aus, but the return
      # also is equivalent to the submit button
     click_button('Save changes') # click 'Save changes'
      expect(page).to have_content('Successfully updated the original combination.') # success msg
      expect(page).to have_content('Cached original combination: Aus specius')

      page.find_link('Edit original combination').click
      # click_link('Edit original combination') # When I click that link
      fill_autocomplete('subject_taxon_name_id_for_tn_rel_0',
                        with: 'Bus', select: 'Bus')
      # select 'Bus' for the original genus ajax select
      click_button('Save changes') # click 'Save changes'
      # I am returned to show for the species in question
      expect(page).to have_content('Successfully updated the original combination.') # success msg
      expect(page).to have_content('Cached original combination: Bus specius')  # show page original genus is changed
    end
  end
end





