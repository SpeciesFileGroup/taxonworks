require 'rails_helper'

describe 'Repositories', :type => :feature do

  it_behaves_like 'a_login_required_controller' do
    let(:index_path) { repositories_path }
    let(:page_index_name) { 'Repositories' }
  end


  context 'signed in as user, with some records created' do
    before {
      sign_in_user
      10.times { factory_girl_create_for_user(:valid_repository, @user) }
    }

    describe 'GET /repositories' do
      before { visit repositories_path }
      specify 'an index name is present' do
        expect(page).to have_content('Repositories')
      end
    end

    describe 'GET /repositories/list' do
      before {
        visit list_repositories_path
      }

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Repositories'
      end
    end

    describe 'GET /repositories/n' do
      before {
        visit repository_path(Repository.second) 
      }

      specify "there is a 'previous' link" do
        expect(page).to have_link('Previous')
      end

      specify "there is a 'next' link" do
        expect(page).to have_link('Next')
      end

    end
  end
end
