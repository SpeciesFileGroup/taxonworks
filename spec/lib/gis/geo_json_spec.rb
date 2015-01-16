require 'rails_helper'

describe Gis::GeoJSON do

  before(:each) do
    clean_slate_geo
    generate_political_areas_with_collecting_events
  end

  after(:all) do
    clean_slate_geo
  end

  context 'outputting GeoJSON "Feature"s ' do
    context 'geographic_item' do
      specify 'that a geographic_item can produce a properly formed feature' do
        # pending
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first.geographic_item]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"geographic_item":{"id":31}},"id":0}]}')
      end

      specify 'that multiple features can be produced by geographic_items' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first.geographic_item,
                                                @ce_old_boxia_2.georeferences.first.geographic_item]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"geographic_item":{"id":31}},"id":0},{"type":"Feature","geometry":{"type":"Point","coordinates":[34.5,25.5,0.0]},"properties":{"geographic_item":{"id":42}},"id":1}]}')
      end
    end

    context 'geographic_area' do
      specify 'that a geographic_area can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.geographic_area]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[[[[36.0,28.0,0.0],[37.0,28.0,0.0],[37.0,27.0,0.0],[36.0,27.0,0.0],[36.0,28.0,0.0]]]]},"properties":{"geographic_area":{"id":57}},"id":0}]}')
      end

    end

    context 'georeference' do
      specify 'that a georeference can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"georeference":{"id":3}},"id":0}]}')
      end

    end

    context 'collecting_event' do
      specify 'that a collecting_event can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"collecting_event":{"id":4}},"id":0}]}')
      end

    end
  end
end
