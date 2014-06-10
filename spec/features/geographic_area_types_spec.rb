require 'spec_helper'

describe 'GeographicAreaTypes', base_class: GeographicAreaType do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /geographic_area_types' do
    before { 
      sign_in_valid_user_and_select_project 
      visit geographic_area_types_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Area Types')
    end
  end
end



