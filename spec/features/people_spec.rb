require 'rails_helper'

describe 'People' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { people_path }
    let(:page_index_name) { 'People' }
  end

  describe 'GET /people' do
    before { 
      sign_in_user_and_select_project 
      visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('People')
    end
  end
end

