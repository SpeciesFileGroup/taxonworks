require 'rails_helper'

describe 'Georeferences', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { georeferences_path }
    let(:page_index_name) { 'Georeferences' }
  end 

  describe 'GET /georeferences' do
    before {
      sign_in_user_and_select_project 
      visit georeferences_path }
    specify 'an index name is present' do
      expect(page).to have_content('Georeferences')
    end
  end
end






