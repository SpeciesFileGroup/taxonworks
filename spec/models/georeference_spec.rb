require 'spec_helper'

describe Georeference do

  let(:georeference) { Georeference.new }
  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }

  context 'associations' do
    context 'belongs_to' do

      specify 'geographic_item' do
        expect(georeference).to respond_to :geographic_item
      end

      specify 'error_geographic_item' do
        expect(georeference).to respond_to :error_geographic_item
      end

      specify 'collecting_event' do
        expect(georeference).to respond_to :collecting_event
      end
    end

  end

  context 'comparison of two adjacent location polygons' do
    specify 'have certain relationships.' do
      c_locator = Georeference::GeoLocate.new(request: request_params)
      c_locator.locate
      u_locator = Georeference::GeoLocate.new(request: {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'})

      c_locator.save
      u_locator.save

      expect(c_locator.error_geographic_item.object.intersects?(u_locator.error_geographic_item.object)).to be_true
      expect(c_locator.geographic_item.object.distance(u_locator.geographic_item.object)).to eq 0.03657760243645799
      expect(c_locator.geographic_item.object.distance(u_locator.error_geographic_item.object)).to eq 0.014470082533135583
      expect(u_locator.geographic_item.object.distance(c_locator.error_geographic_item.object)).to eq 0.021583346308561287
    end
  end

  context 'methods provide that' do
    context 'the object returns a type' do
      specify 'which is GeoLocate' do

        georeference = Georeference::GeoLocate.new(request: {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'})
        georeference.build
        georeference.save

        expect(georeference.type).to eq 'Georeference::GeoLocate'
      end

      specify 'which is Verbatim' do
        georeference = Georeference::VerbatimData.new

        expect(georeference.type).to eq 'Georeference::VerbatimData'
      end
    end
  end


end
