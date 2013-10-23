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
  end
end
