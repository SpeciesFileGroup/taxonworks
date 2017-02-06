require 'rails_helper'

describe 'Repositories', :type => :feature do
  let(:index_path) { repositories_path }
  let(:page_title) { 'Repositories' }

  it_behaves_like 'a_login_required_controller'

  context 'signed in as user, with some records created' do
    before {
      sign_in_user
      10.times { factory_girl_create_for_user(:valid_repository, @user) }
    }

    describe 'GET /repositories' do
      before { visit repositories_path }

      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /repositories/list' do
      before {
        visit list_repositories_path
      }

      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /repositories/n' do
      before {
        visit repository_path(Repository.second)
      }

      it_behaves_like 'a_data_model_with_standard_show'
    end
  end
end
