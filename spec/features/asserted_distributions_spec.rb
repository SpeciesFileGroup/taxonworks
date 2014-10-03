require 'rails_helper'

describe "AssertedDistributions", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { asserted_distributions_path }
    let(:page_index_name) { 'Asserted Distributions' }
  end

  describe 'GET /asserted_distributions' do
    before {
      sign_in_user_and_select_project
      visit asserted_distributions_path }

    specify 'a index name is present' do
      expect(page).to have_content('Asserted Distributions')
    end
  end

  describe 'GET /asserted_distributions/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there is more than one page
      30.times { FactoryGirl.create(:valid_asserted_distribution) }
      visit '/asserted_distributions/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing asserted distributions'
    end
  end

  describe 'GET /asserted_distributions/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_asserted_distribution) }
      all_asserted_distributions = AssertedDistribution.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/asserted_distributions/#{all_asserted_distributions[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end
