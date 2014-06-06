require 'spec_helper'

describe 'GeographicAreasGeographicItems' do
  describe 'GET /geographic_areas_geographic_items' do
    before { visit geographic_areas_geographic_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Areas Geographic Items')
    end
  end
end




