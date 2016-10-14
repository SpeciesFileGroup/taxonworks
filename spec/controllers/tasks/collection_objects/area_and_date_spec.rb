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
      expect(JSON.parse(response.body)['html']).to eq('16')
    end

    it 'renders count of collection objects in a drawn area' do
      # {"type"=>"Feature", "geometry"=>{"type"=>"MultiPolygon", "coordinates"=>[[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]}, "properties"=>{"geographic_item"=>{"id"=>23}}}
      get(:set_area, {drawn_area_shape: GeographicArea
                                          .where(name: 'Big Boxia')
                                          .first
                                          .default_geographic_item
                                          .to_geo_json_feature})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('10')
    end
  end

  describe '#set_date' do
    it 'renders count of collection objects based on the start and end dates' do
      get(:set_date, {st_flexpicker: Date.parse('1971/01/01').to_s.gsub('-', '/'), en_flexpicker: Date.parse('1980/12/31').to_s.gsub('-', '/')})
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['html']).to eq('10')
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
      result = JSON.parse(response.body)
      expect(result['collection_objects_count']).to eq('3')
      features          = result['feature_collection']['features']
      georeference_id   = features[0]['properties']['georeference']['id']
      collecting_events = [Georeference.find(georeference_id).collecting_event.verbatim_label]
      georeference_id   = features[1]['properties']['georeference']['id']
      collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
      georeference_id = features[2]['properties']['georeference']['id']
      collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
      expect(collecting_events).to include('@ce_m1', '@ce_m1a', '@ce_m2 in Big Boxia')
    end

    describe 'certain specific combinations of collecting event dates' do

      it 'spans a single day' do
        get(:find, {st_flexpicker:    '1981/01/01',
                    en_flexpicker:    '1981/1/1',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('1')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m3')
      end

      it 'spans a single month' do
        get(:find, {st_flexpicker:    '1974/04/01',
                    en_flexpicker:    '1974/4/30',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('1')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_p1')
      end

      it 'spans a single year' do
        get(:find, {st_flexpicker:    '1971/01/01',
                    en_flexpicker:    '1971/12/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('2')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1')
        georeference_id = result['feature_collection']['features'][1]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
      end

      it 'spans four months of a year' do
        get(:find, {st_flexpicker:    '1971/05/01',
                    en_flexpicker:    '1971/8/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('1')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
      end

      it 'spans a partial year' do
        get(:find, {st_flexpicker:    '1971/01/01',
                    en_flexpicker:    '1971/08/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('2')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1')
        georeference_id = result['feature_collection']['features'][1]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
      end

      it 'spans parts of two years' do
        get(:find, {st_flexpicker:    '1974/03/01',
                    en_flexpicker:    '1975/6/30',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('2')
        features          = result['feature_collection']['features']
        georeference_id   = features[0]['properties']['georeference']['id']
        collecting_events = [Georeference.find(georeference_id).collecting_event.verbatim_label]
        georeference_id   = features[1]['properties']['georeference']['id']
        collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
        expect(collecting_events).to include('@ce_m2 in Big Boxia', '@ce_p1')
      end

      it 'spans parts of several years' do
        get(:find, {st_flexpicker:    '1974/03/01',
                    en_flexpicker:    '1976/08/31',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('4')
        features          = result['feature_collection']['features']
        georeference_id   = features[0]['properties']['georeference']['id']
        collecting_events = [Georeference.find(georeference_id).collecting_event.verbatim_label]
        georeference_id   = features[1]['properties']['georeference']['id']
        collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
        georeference_id = features[2]['properties']['georeference']['id']
        collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
        georeference_id = features[3]['properties']['georeference']['id']
        collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
        expect(collecting_events).to include('@ce_m2 in Big Boxia', '@ce_p1', '@ce_n2', '@ce_n2')
      end

      # following two tests obviated by ambiguity in comparison of ranges
      xit 'excludes parts of two years in a non-greedy search for 1982/02/02-1984/09/15' do
        get(:find, {st_flexpicker:    '1982/02/01',
                    en_flexpicker:    '1984/6/30',
                    greedy:           'off',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('0')
      end

      xit 'spans parts of two years in a non-greedy search' do
        get(:find, {st_flexpicker:    '1982/02/01',
                    en_flexpicker:    '1984/9/30',
                    greedy:           'off',
                    drawn_area_shape: GeographicArea
                                        .where(name: 'Great Northern Land Mass')
                                        .first
                                        .default_geographic_item
                                        .to_geo_json_feature})
        result = JSON.parse(response.body)
        expect(result['collection_objects_count']).to eq('1')
        georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
        expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_n3')
      end
    end
  end
end
