require 'spec_helper'

describe 'GeographicAreasGeographicItems' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /geographic_areas_geographic_items' do
    before { visit geographic_areas_geographic_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Areas Geographic Items')
    end
  end
end




