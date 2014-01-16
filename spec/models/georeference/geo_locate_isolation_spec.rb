require 'spec_helper'

describe Georeference::GeoLocate do

  let(:geo_locate) { Georeference::GeoLocate.new }
  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }
  let(:set_request) {
    geo_locate.request = request_params
  }

  context 'methods' do

    context 'request contains doUncert = false (non-default)' do
      specify 'that .error_radius is zero' do

        geo_locate_2 = Georeference::GeoLocate.new(request: request_params)
        geo_locate_2.build

        set_request
        geo_locate.request[:doUncert] = false
        geo_locate.build

        # make sure they are the same point
        expect(geo_locate.geographic_item.point).to eq geo_locate_2.geographic_item.point
        expect(geo_locate.error_radius).not_to eq geo_locate_2.error_radius
        expect(geo_locate.error_radius).to eq 0
      end
    end

  end
end
