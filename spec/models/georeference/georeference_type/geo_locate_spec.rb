require 'spec_helper'

describe Georeference::GeoreferenceType::GeoLocate do

  before :all do

  end

  context 'on invocation of \'locate\'' do

    specify 'that the locator can do certain things, or not.' do
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new

      geo_locator.locate(country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true')

      expect(geo_locator.request).to eq '?country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(geo_locator.geographic_item_id).not_to be_nil
      expect(geo_locator.error_geographic_item_id).not_to be_nil
      expect(geo_locator.error_radius).to eq 7338
    end
  end

  context 'on invocation of \'new\' with a valid request.' do
    specify 'that the object fills itself in.' do
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new(request: '?country=USA&state=IL&locality=Urbana&dopoly=true')

      expect(geo_locator.request).to eq '?country=USA&state=IL&locality=Urbana&dopoly=true'
      expect(geo_locator.error_radius).to eq 5592.0
      expect(geo_locator.error_geographic_item.object.contains?(geo_locator.geographic_item.object)).to be_true
    end
  end

  context 'on invocation of \'new\' with an invalid request.' do
    specify 'that the object fills itself in.' do
      this_request = '?country=USA&locality=Urbana&dopoly=true'
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new(request: this_request)

      expect(geo_locator.request).to eq this_request
      expect(geo_locator.error_radius).to be_nil
#      expect(geo_locator.error_geographic_item.object.contains?(geo_locator.geographic_item.object)).to be_true
    end
  end

  context 'compare two adjacent location polygons' do
    specify 'that the two have certain relationships.' do
      c_locator = Georeference::GeoreferenceType::GeoLocate.new
      c_locator.locate(country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true')
      u_locator = Georeference::GeoreferenceType::GeoLocate.new(request: '?country=USA&locality=Urbana&state=IL&dopoly=true')

      expect(c_locator.error_geographic_item.object.intersects?(u_locator.error_geographic_item.object)).to be_true
      expect(c_locator.geographic_item.object.distance(u_locator.geographic_item.object)).to eq 0.03657760243645799
      expect(c_locator.geographic_item.object.distance(u_locator.error_geographic_item.object)).to eq 0.014470082533135583
      expect(u_locator.geographic_item.object.distance(c_locator.error_geographic_item.object)).to eq 0.021583346308561287

      end
  end
end
