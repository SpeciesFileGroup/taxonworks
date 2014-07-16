require 'rails_helper'

describe 'GeographicAreaTypes' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { geographic_area_types_path }
    let(:page_index_name) { 'Geographic Area Types' }
  end

  describe 'GET /geographic_area_types' do
    before { 
      sign_in_user_and_select_project 
      visit geographic_area_types_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Area Types')
    end
  end
end



