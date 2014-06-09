require 'spec_helper'

describe 'GeographicAreas', base_class: GeographicArea do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /geographic_areas' do
    before { visit geographic_areas_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Areas')
    end
  end
end




