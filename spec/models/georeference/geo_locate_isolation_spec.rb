require 'spec_helper'

describe Georeference::GeoLocate do

  let(:geo_locate) {Georeference::GeoLocate.new}
  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }
  let(:set_request) {
    geo_locate.request = request_params
  }

  context 'on new() with a valid request.' do
    specify 'build() successfully completes' do
      g = Georeference::GeoLocate.new(request: request_params)  # TODO: make hash})
      expect(g.api_request).to eq 'country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(g.error_radius).to eq 5592.0
      expect(g.error_geographic_item.object.contains?(geo_locate.geographic_item.object)).to be_true
    end
  end

end
