require 'spec_helper'

describe 'Notes' do
  
  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { notes_path }
    let(:page_index_name) { 'Notes' }
  end 

  describe 'GET /Notes' do
    before { 
      sign_in_valid_user_and_select_project 
      visit notes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Notes')
    end
  end
end
