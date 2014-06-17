require 'spec_helper'

describe 'Namespaces' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { namespaces_path }
    let(:page_index_name) { 'Namespaces' }
  end 

  describe 'GET /Namespaces' do
    before {
      sign_in_valid_user_and_select_project 
      visit namespaces_path }
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
end








