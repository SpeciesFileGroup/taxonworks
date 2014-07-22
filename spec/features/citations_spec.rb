require 'rails_helper'

describe 'Citations' do

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
end
