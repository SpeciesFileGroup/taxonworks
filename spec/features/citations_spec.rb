require 'rails_helper'

describe 'Citations', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { citations_path }
    let(:page_index_name) { 'Citations' }
  end

  describe 'GET /citations' do
    before {
      sign_in_valid_user_and_select_project
      visit citations_path }

    specify 'an index name is present' do
      expect(page).to have_content('Citations')
    end

  end

  describe 'GET /citations/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of citations
      30.times { FactoryGirl.create(:valid_citation) }
      visit '/citations/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Citations'
    end

  end

  describe 'GET /citations/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_citation) }
      all_citations = Citation.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/citations/#{all_citations[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end
end
