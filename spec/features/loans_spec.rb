require 'rails_helper'

describe 'Loans' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { loans_path }
    let(:page_index_name) { 'Loans' }
  end 

  describe 'GET /loans' do
    before { 
      sign_in_user_and_select_project 
      visit loans_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loans')
    end
  end
end
