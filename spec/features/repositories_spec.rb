require 'rails_helper'

describe 'Repositories' do

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
end


