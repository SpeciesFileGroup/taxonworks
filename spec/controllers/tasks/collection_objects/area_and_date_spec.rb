require 'rails_helper'

describe Tasks::CollectionObjects::AreaAndDateController, type: :controller do
  # include DataControllerConfiguration::ProjectDataControllerConfiguration

  before(:all) {
    # sign_in
    generate_political_areas_with_collecting_events
  }
  before(:each) {
    sign_in
  }
  after(:all) { clean_slate_geo }

  describe 'GET #index' do
    it 'returns http success' do
      get(:index)
      expect(response).to have_http_status(:success)
    end
  end

  describe '#set_area' do
    it 'renders count of collection objects in a specific names area' do
      get(:set_area, {geographic_area_id: GeographicArea.where(name: 'Great Northern Land Mass').first.id})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('13')
    end

    it 'renders count of collection objects in a drawn area' do
      # {"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}
      get(:set_area, {drawn_area_shape: GeographicArea
                                          .where(name: 'Big Boxia')
                                          .first
                                          .default_geographic_item
                                          .to_geo_json_feature})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('7')
    end
  end

  describe '#set_date' do
    it 'renders count of collection objects based on the start and end dates' do
      get(:set_date, {st_flexpicker: Date.parse('1971/01/01').to_s.gsub('-', '/'), en_flexpicker: Date.parse('1980/12/31').to_s.gsub('-', '/')})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('8')
    end
  end
  describe '#find' do
    it 'renders dwca of the selected collection objects, and geo_json feature collection' do
      get(:find, {st_flexpicker:    Date.parse('1971/01/01').to_s.gsub('-', '/'),
                  en_flexpicker:    Date.parse('1980/12/31').to_s.gsub('-', '/'),
                  drawn_area_shape: GeographicArea
                                      .where(name: 'West Boxia')
                                      .first
                                      .default_geographic_item
                                      .to_geo_json_feature})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['collection_objects_count']).to eq('2')
      fc = JSON.parse(response.body)['feature_collection']
      expect(fc).to eq({'type'     => 'FeatureCollection',
                        'features' => [{'type'       => 'Feature',
                                        'geometry'   => {'type'        => 'Point',
                                                         'coordinates' => [33.5, 27.5, 0.0]},
                                        'properties' => {'georeference' => {'id'  => 1,
                                                                            'tag' => 'Georeference ID = 1'}},
                                        'id'         => 1},
                                       {'type'       => 'Feature',
                                        'geometry'   => {'type'        => 'Point',
                                                         'coordinates' => [33.5, 26.5, 0.0]},
                                        'properties' => {'georeference' => {'id'  => 4,
                                                                            'tag' => 'Georeference ID = 4'}},
                                        'id'         => 2}]})
    end

    describe 'certain specific combinations of collecting event dates' do

      it 'spans a single day' do
        get(:find, {st_flexpicker:    '1971/01/01',
                    en_flexpicker:    '1971/1/1',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        expect(JSON.parse(response.body)['collection_objects_count']).to eq('1')
      end

      it 'spans a single month' do
        get(:find, {st_flexpicker:    '1974/04/01',
                    en_flexpicker:    '1974/4/30',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        expect(JSON.parse(response.body)['collection_objects_count']).to eq('1')
      end

      it 'spans a single year' do
        get(:find, {st_flexpicker:    '1973/01/01',
                    en_flexpicker:    '1973/12/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        expect(JSON.parse(response.body)['collection_objects_count']).to eq('1')
      end

      it 'spans a partial year' do
        get(:find, {st_flexpicker:    '1973/01/01',
                    en_flexpicker:    '1973/12/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        expect(JSON.parse(response.body)['collection_objects_count']).to eq('1')
      end

      it 'spans part of two year' do
        get(:find, {st_flexpicker:    '1974/03/01',
                    en_flexpicker:    '1975/6/30',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        expect(JSON.parse(response.body)['collection_objects_count']).to eq('2')
      end
    end
  end
end
