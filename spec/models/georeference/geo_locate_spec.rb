require 'spec_helper'

describe Georeference::GeoLocate do

  let(:geo_locate) {Georeference::GeoLocate.new}
  let(:request_params) { 
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }

  context 'methods' do
    specify '.build_request builds a request string' do
      expect(geo_locate.build_request(request_params)).to be_true 
      expect(geo_locate.read_attribute(:api_request)).to eq('country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json')
    end

    specify 'locate() populates @response' do
      geo_locate.locate(request_params)
      expect(geo_locate.response).not_to be_nil
    end

    specify '#build_geographic_item populates #geographic_item when @response contains a result' do
      geo_locate.locate(request_params)
      geo_locate.build_geographic_item
      expect(geo_locate.geographic_item).not_to be_nil
    end

    specify '#build_georeference_error populates #error_geographic_item when @response contains a result' do
      geo_locate.locate(request_params)
      geo_locate.build_georeference_error
      expect(geo_locate.build_georeference_error).not_to be_nil
      expect(geo_locate.error_radius).to eq 7338
    end

    specify '.build wraps the whole process' do
      pending 
    end
  end

  context 'new() without a request' do
    specify 'instance is valid' do
      expect(geo_locate.valid?).to be_true
    end
  end

  context 'on new() with a valid request.' do
    specify 'build() successfully completes' do
      g = Georeference::GeoLocate.new(request_params)  # TODO: make hash})
      expect(g.api_request).to eq 'country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(g.error_radius).to eq 5592.0
      expect(g.error_geographic_item.object.contains?(geo_locate.geographic_item.object)).to be_true
    end
  end

  context 'on invocation of new() with an invalid request' do
    specify 'errors are added to api_request' do
      pending
    end

   #specify 'that the object fills itself in' do
   #  this_request = '?country=USA&locality=Urbana&dopoly=true'
   #  geo_locate = Georeference::GeoLocate.new(request: this_request)

   #  expect(geo_locate.request).to eq this_request
   #  expect(geo_locate.error_radius).to be_nil
   #  #      expect(geo_locate.error_geographic_item.object.contains?(geo_locate.geographic_item.object)).to be_true
   #end
  end

  # TODO: this is a Georeference test
  context 'compare two adjacent location polygons' do
    specify 'that the two have certain relationships.' do
      c_locator = Georeference::GeoLocate.new
      c_locator.locate(country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true')
      u_locator = Georeference::GeoLocate.new(request: '?country=USA&locality=Urbana&state=IL&dopoly=true')

      expect(c_locator.error_geographic_item.object.intersects?(u_locator.error_geographic_item.object)).to be_true
      expect(c_locator.geographic_item.object.distance(u_locator.geographic_item.object)).to eq 0.03657760243645799
      expect(c_locator.geographic_item.object.distance(u_locator.error_geographic_item.object)).to eq 0.014470082533135583
      expect(u_locator.geographic_item.object.distance(c_locator.error_geographic_item.object)).to eq 0.021583346308561287
    end
  end
end
