require 'rails_helper'

describe 'GeographicAreas' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { geographic_areas_path }
    let(:page_index_name) { 'Geographic Areas' }
  end  

  describe 'GET /geographic_areas' do
    before {
      sign_in_user_and_select_project 
      visit geographic_areas_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Areas')
    end
  end
end




