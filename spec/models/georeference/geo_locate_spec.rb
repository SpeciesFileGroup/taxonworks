require 'rails_helper'

describe Georeference::GeoLocate, :type => :model do

  let(:geo_locate) { FactoryGirl.build(:georeference_geo_locate) }
  let(:request_params) { {country: 'USA', state: 'IL', doPoly: 'true', locality: 'Urbana'} }
  let(:request) { Georeference::GeoLocate::Request.new(request_params) }
  let(:response) { VCR.use_cassette('geo-locate-with-request') { request.response } }
  let(:georeference_from_build) { VCR.use_cassette('geo-locate-with-build') { Georeference::GeoLocate.build(request_params) } }

  context 'building a Georeference::GeoLocate with #build_from_embedded_result(response_string)' do
    before(:each) {
      @a = Georeference::GeoLocate.build_from_embedded_result(GEO_LOCATE_STRING)
    }

    specify 'with a collecting event, is valid' do
      @a.collecting_event = FactoryGirl.build(:valid_collecting_event)
      expect(@a.valid?).to be_truthy
    end

  end

  context 'building a Georeference::GeoLocate with #build' do
    before(:each) {
      @a = georeference_from_build
    }

    specify '#build builds a Georeference::GeoLocate instance' do
      expect(@a.class).to eq(Georeference::GeoLocate)
    end

    specify '#build(request_params) passes' do
      VCR.use_cassette('geo-locate-with-build') do
        expect(Georeference::GeoLocate.build(request_params)).to be_truthy
      end
    end

    specify 'with a collecting event #build produces a valid instance' do
      @a.collecting_event = FactoryGirl.build(:valid_collecting_event)
      expect(@a.valid?).to be_truthy
    end

    specify 'a built, valid, instance is geometrically(?) correct' do
      @a.collecting_event = FactoryGirl.build(:valid_collecting_event)
      expect(@a.save).to be_truthy
      expect(@a.error_geographic_item.geo_object.contains?(@a.geographic_item.geo_object)).to be_truthy
    end

    specify 'with invalid parameters returns a Georeference::GeoLocate instance with errors on :base' do
      VCR.use_cassette('geo-locate-with-build-using-empty-country-param') do
        @a = Georeference::GeoLocate.build(country: '')
        expect(@a.errors.include?(:api_request)).to be_truthy
      end
    end

    specify '#with doPoly false instance should have no error polygon' do
      VCR.use_cassette('geo-locate-with-build-using-false-doPoly-param') do
        @a = Georeference::GeoLocate.build({country: 'usa', state: 'IL', doPoly: 'false', locality: 'Urbana'})
        expect(@a.error_geographic_item.nil?).to be_truthy
      end
    end

    # Note: three meters was chosen as a minimum, because that is (usually) the smallest circle of uncertainty provided by current GPS units.
    specify 'with doUncert false error_radius should be 3(?)' do
      VCR.use_cassette('geo-locate-with-build-using-false-doUncert-param') do
        @a = Georeference::GeoLocate.build({country:  'usa', state: 'IL', doPoly: 'true',
                                            locality: 'Urbana', doUncert: 'false'})
        expect(@a.error_radius).to eq(3)
      end
    end
  end

  context 'instance methods' do
    specify 'api_response=(response) populates .geographic_item' do
      expect(geo_locate.api_response = response).to be_truthy
      expect(geo_locate.geographic_item).not_to be_nil
      expect(geo_locate.geographic_item.class).to eq(GeographicItem)
      expect(geo_locate.geographic_item.geo_object.class).to eq(RGeo::Geographic::ProjectedPointImpl)
    end

    specify 'api_response=(response.result) populates .error_geographic_item' do
      expect(geo_locate.api_response = response).to be_truthy
      expect(geo_locate.error_geographic_item).not_to be_nil
      expect(geo_locate.error_radius.to_i > 5000).to be_truthy # Bad test
    end

    specify '.request_hash' do
      expect(georeference_from_build.request_hash).to eq({"country"      => "USA",
                                                          "state"        => "IL",
                                                          "county"       => "",
                                                          "locality"     => "Urbana",
                                                          "enableH2O"    => "false",
                                                          "hwyX"         => "false",
                                                          "doUncert"     => "true",
                                                          "doPoly"       => "true",
                                                          "displacePoly" => "false",
                                                          "languageKey"  => "0",
                                                          "fmt"          => "json"})
    end
  end


  context 'Request' do
    specify 'has a @response' do
      expect(request.respond_to?(:response)).to be_truthy
    end

    specify 'has @request_params' do
      expect(request.request_params).to eq(Georeference::GeoLocate::Request::REQUEST_PARAMS.merge(request_params))
    end

    specify 'has @request_param_string' do
      expect(request.request_param_string).to be(nil)
    end

    specify '.build_param_string' do # '.make_request builds a request string' do
      expect(request.build_param_string).to be_truthy
      expect(request.request_param_string).to eq('country=USA&state=IL&county=&locality=Urbana&enableH2O=false&hwyX=false&doUncert=true&doPoly=true&displacePoly=false&languageKey=0&fmt=json')
    end

    specify '.locate' do
      VCR.use_cassette('geo-locate-with-locate') { expect(request.locate).to be_truthy }
    end

    specify '.locate populates @response' do
      VCR.use_cassette('geo-locate-with-locate') do
        expect(request.locate).to be_truthy
        expect(request.response).to_not be_nil
        expect(request.response.class).to eq(Georeference::GeoLocate::Response)
      end
    end

    specify '.succeeded?' do
      VCR.use_cassette('geo-locate-with-locate') do
        expect(request.locate).to be_truthy
        expect(request.succeeded?).to be_truthy
      end
    end
  end

  context 'Response' do
    specify 'contains some @result (in json)' do
      VCR.use_cassette('geo-locate-with-locate') do
        request.locate
        expect(response.result.keys.include?('numResults')).to be_truthy
      end
    end
  end

end
