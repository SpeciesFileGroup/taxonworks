require 'rails_helper'

describe 'Repositories', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { repositories_path }
    let(:page_index_name) { 'Repositories' }
  end

  describe 'GET /repositories' do
    before {
      sign_in_user_and_select_project
      visit repositories_path }

    specify 'an index name is present' do
      expect(page).to have_content('Repositories')
    end
  end

  describe 'GET /repositories/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of repositories
      30.times { FactoryGirl.create(:valid_repository) }
      visit '/repositories/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Repositories'
    end

  end

  describe 'GET /repositories/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_repository) }
      all_repositories = Repository.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/repositories/#{all_repositories[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end


