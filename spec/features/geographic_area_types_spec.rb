require 'spec_helper'

describe 'GeographicAreaTypes' do
  describe 'GET /geographic_area_types' do
    before { visit geographic_area_types_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing geographic_area_types')
    end
  end
end



