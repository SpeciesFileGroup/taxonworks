require 'spec_helper'

describe 'GeographicAreas' do
  describe 'GET /geographic_areas' do
    before { visit geographic_areas_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing geographic_areas')
    end
  end
end




