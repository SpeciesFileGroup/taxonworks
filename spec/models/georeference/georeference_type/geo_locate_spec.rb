require 'spec_helper'

describe Georeference::GeoreferenceType::GeoLocate do

  before :all do

  end

  context 'on invocation of \'locate\'' do

    specify 'that the locator can do certain things, or not.' do
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new
      u_geo_locator = Georeference::GeoreferenceType::GeoLocate.new(request: '?country=USA&locality=Urbana&state=IL&dopoly=true')

      geo_locator.locate(country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true')

      expect(geo_locator.request).to eq '?country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(geo_locator.geographic_item_id).not_to be_nil
      expect(geo_locator.error_geographic_item_id).not_to be_nil
      expect(geo_locator.error_radius).to eq 7338
    end
  end

=begin
  context 'on invocation of \'new\'.' do
    specify 'that the object fills itself in.' do
      geo_locator = Georeference::GeoreferenceType::GeoLocate.new(request: '?country=USA&state=IL&locality=Urbana&dopoly=true')

      expect(geo_locator.request).to eq '?country=USA&state=IL&locality=Urbana&dopoly=true'
      expect(geo_locator.geographic_item_id).not_to be_nil
      expect(geo_locator.error_geographic_item_id).not_to be_nil
      expect(geo_locator.error_radius).to eq 7338
    end
  end
=end

  context 'compare to adjacent location polygons' do
    specify 'that the two have certain relationships.' do
      c_locator = Georeference::GeoreferenceType::GeoLocate.new
      u_locator = Georeference::GeoreferenceType::GeoLocate.new

      c_locator.locate(country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true')
      u_locator.locate(country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true')

      expect(c_locator.request).to eq '?country=usa&state=illinois&county=&locality=champaign&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(u_locator.request).to eq '?country=USA&state=IL&county=&locality=Urbana&hwyX=false&enableH2O=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json'
      expect(c_locator.geographic_item_id).not_to be_nil
      end
  end
end
