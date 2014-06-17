require 'spec_helper'

describe 'Identifiers' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { identifiers_path }
    let(:page_index_name) { 'Identifiers' }
  end 

  describe 'GET /identifiers' do
    before { 
      sign_in_valid_user_and_select_project 
      visit identifiers_path 
    }
    specify 'an index name is present' do
      expect(page).to have_content('Identifiers')
    end
  end
end







