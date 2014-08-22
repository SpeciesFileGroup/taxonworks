require 'rails_helper'

describe 'TaxonNames', :type => :feature do

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
  describe 'GET /taxon_names/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of taxon_names
      30.times { FactoryGirl.create(:valid_taxon_name) }
      visit '/taxon_names/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Taxon Names'
    end

  end

  describe 'GET /taxon_names/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_taxon_name) }
      all_taxon_names = TaxonName.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/taxon_names/#{all_taxon_names[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end






