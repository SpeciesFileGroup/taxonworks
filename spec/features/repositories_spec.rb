require 'spec_helper'

describe 'Repositories', base_class: Repository do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /repositories' do
    before { 
     sign_in_valid_user_and_select_project 
      visit repositories_path }
    specify 'an index name is present' do
      expect(page).to have_content('Repositories')
    end
  end
end


